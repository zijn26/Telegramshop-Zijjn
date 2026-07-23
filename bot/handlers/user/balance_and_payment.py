import hashlib
import json
import random
from decimal import Decimal, ROUND_HALF_UP
from html import escape as html_escape

from aiogram import Router, F
from aiogram.types import CallbackQuery, Message, PreCheckoutQuery, SuccessfulPayment
from aiogram.fsm.context import FSMContext
from aiogram.exceptions import TelegramBadRequest, TelegramForbiddenError

from bot.database.methods import get_user_referral, buy_item_transaction, process_payment_with_referral, create_pending_payment
from bot.keyboards import back, payment_menu, close, get_payment_choice
from bot.logger_mesh import logger
from bot.database.methods.audit import log_audit
from bot.misc import EnvKeys, ItemPurchaseRequest, validate_telegram_id, validate_money_amount, PaymentRequest, \
    sanitize_html
from bot.handlers.other import _any_payment_method_enabled, is_safe_item_name
from bot.misc.metrics import get_metrics
from bot.misc.services import CryptoPayAPI, CryptoPayAPIError, PayOSAPI, PayOSAPIError, send_stars_invoice, send_fiat_invoice
from bot.misc.services.payment import _minor_units_for
from bot.filters import ValidAmountFilter
from bot.i18n import localize
from bot.states import BalanceStates

router = Router()


async def _notify_referrer_bonus(bot, user_id: int, amount: Decimal | int, payer_name: str, payer_id: int):
    """Send referral bonus notification to the referrer if applicable."""
    referral_id = await get_user_referral(user_id)
    if not referral_id or not EnvKeys.REFERRAL_PERCENT:
        return
    try:
        clamped_percent = min(max(EnvKeys.REFERRAL_PERCENT, 0), 99)
        bonus = (Decimal(clamped_percent) / Decimal(100) * Decimal(amount)).quantize(Decimal("0.01"))
        if bonus > 0:
            await bot.send_message(
                referral_id,
                localize('payments.referral.bonus',
                         amount=bonus, name=html_escape(payer_name or ''),
                         id=payer_id, currency=EnvKeys.PAY_CURRENCY),
                reply_markup=close()
            )
    except (TelegramBadRequest, TelegramForbiddenError) as e:
        logger.error(f"Failed to send referral notification to user {referral_id}: {e}")


@router.callback_query(F.data == "replenish_balance")
async def replenish_balance_callback_handler(call: CallbackQuery, state: FSMContext):
    """Ask user for the amount if at least one payment method is enabled."""
    if not _any_payment_method_enabled():
        await call.answer(localize("payments.not_configured"), show_alert=True)
        return

    await call.message.edit_text(
        localize("payments.replenish_prompt", currency=EnvKeys.PAY_CURRENCY),
        reply_markup=back('back_to_menu')
    )
    await state.set_state(BalanceStates.waiting_amount)


@router.message(BalanceStates.waiting_amount, ValidAmountFilter())
async def replenish_balance_amount(message: Message, state: FSMContext):
    """Store amount and show payment methods."""
    try:
        # Validate amount using Pydantic
        amount = validate_money_amount(
            message.text,
            min_amount=Decimal(EnvKeys.MIN_AMOUNT),
            max_amount=Decimal(EnvKeys.MAX_AMOUNT)
        )

        await state.update_data(amount=int(amount))

        await message.answer(
            localize("payments.method_choose"),
            reply_markup=get_payment_choice()
        )
        await state.set_state(BalanceStates.waiting_payment)

    except ValueError as e:
        await message.answer(
            localize("payments.replenish_invalid",
                     min_amount=EnvKeys.MIN_AMOUNT,
                     max_amount=EnvKeys.MAX_AMOUNT,
                     currency=EnvKeys.PAY_CURRENCY),
            reply_markup=back('replenish_balance')
        )


@router.message(BalanceStates.waiting_amount)
async def invalid_amount(message: Message, state: FSMContext):
    """
    Tell user the amount is invalid.
    """
    await message.answer(
        localize("payments.replenish_invalid",
                 min_amount=EnvKeys.MIN_AMOUNT,
                 max_amount=EnvKeys.MAX_AMOUNT,
                 currency=EnvKeys.PAY_CURRENCY),
        reply_markup=back('replenish_balance')
    )


@router.callback_query(
    BalanceStates.waiting_payment,
    F.data.in_(["pay_payos", "pay_cryptopay", "pay_stars", "pay_fiat"])
)
async def process_replenish_balance(call: CallbackQuery, state: FSMContext):
    """Create an invoice for the chosen payment method."""
    data = await state.get_data()
    amount = data.get('amount')

    if amount is None:
        await call.answer(localize("payments.session_expired"), show_alert=True)
        await call.message.edit_text(localize("menu.title"), reply_markup=back('back_to_menu'))
        await state.clear()
        return

    # Map callback data to provider
    provider_map = {
        "pay_payos": "payos",
        "pay_cryptopay": "cryptopay",
        "pay_stars": "stars",
        "pay_fiat": "fiat"
    }
    provider = provider_map.get(call.data)

    try:
        # Validate payment request
        payment_request = PaymentRequest(
            amount=Decimal(amount),
            currency=EnvKeys.PAY_CURRENCY,
            provider=provider
        )

        amount_dec = payment_request.amount
        ttl_seconds = int(EnvKeys.PAYMENT_TIME)

        if call.data == "pay_payos":
            if not (EnvKeys.PAYOS_CLIENT_ID and EnvKeys.PAYOS_API_KEY and EnvKeys.PAYOS_CHECKSUM_KEY):
                await call.answer(localize("payments.not_configured"), show_alert=True)
                return

            try:
                import time
                from urllib.parse import quote_plus
                order_code = int(time.time() * 1000) % 9007199254740991
                payos = PayOSAPI()

                bot_info = await call.bot.get_me()
                redirect_url = f"https://t.me/{bot_info.username}"

                random_code = random.randint(100000000, 999999999)
                invoice = await payos.create_payment_link(
                    order_code=order_code,
                    amount=int(amount_dec),
                    description=f"{random_code}",
                    cancel_url=redirect_url,
                    return_url=redirect_url,
                )
            except PayOSAPIError as e:
                await log_audit("payos_error", level="ERROR", user_id=call.from_user.id, resource_type="Payment", details=f"[{e.code}] {e.desc}")
                await call.answer(localize("payments.payos.api_error", error=e.desc), show_alert=True)
                return
            except Exception as e:
                await log_audit("payos_invoice_fail", level="ERROR", user_id=call.from_user.id, resource_type="Payment", details=str(e))
                await call.answer(localize("payments.payos.create_fail", error=str(e)), show_alert=True)
                return

            pay_url = invoice.get("checkoutUrl", "")
            bin_code = invoice.get("bin", "")
            account_no = invoice.get("accountNumber", "")
            account_name = invoice.get("accountName", "")
            order_desc = invoice.get("description", str(random_code))
            qr_code_str = invoice.get("qrCode", "")

            if bin_code and account_no:
                qr_image_url = f"https://img.vietqr.io/image/{bin_code}-{account_no}-compact2.png?amount={int(amount_dec)}&addInfo={quote_plus(str(order_desc))}&accountName={quote_plus(str(account_name))}"
            elif qr_code_str:
                qr_image_url = f"https://api.qrserver.com/v1/create-qr-code/?size=400x400&data={quote_plus(qr_code_str)}"
            else:
                qr_image_url = f"https://api.qrserver.com/v1/create-qr-code/?size=400x400&data={quote_plus(pay_url)}"

            await create_pending_payment(
                provider="payos",
                external_id=str(order_code),
                user_id=call.from_user.id,
                amount=int(amount_dec),
                currency=payment_request.currency,
            )

            await state.update_data(invoice_id=str(order_code), payment_type="payos")

            formatted_amount = f"{int(amount_dec):,}".replace(",", ".")
            caption = (
                f"📲 <b>MÃ VIETQR THANH TOÁN (PayOS)</b>\n\n"
                f"💳 <b>Số tài khoản</b>: <code>{account_no}</code>\n"
                f"👤 <b>Chủ tài khoản</b>: <b>{html_escape(account_name)}</b>\n"
                f"💵 <b>Số tiền</b>: <code>{formatted_amount}</code> {payment_request.currency}\n"
                f"📝 <b>Nội dung chuyển khoản</b>: <code>{html_escape(order_desc)}</code>\n\n"
                f"⚠️ <b>LƯU Ý QUAN TRỌNG:</b>\n"
                f"• Nhấp vào số tài khoản hoặc nội dung để <b>sao chép nhanh</b>.\n"
                f"• Chuyển <b>chính xác số tiền</b> và <b>nội dung chuyển khoản</b>.\n"
                f"• Hóa đơn có hiệu lực trong <b>{int(ttl_seconds / 60)} phút</b>.\n\n"
                f"<i>Sau khi chuyển khoản xong, vui lòng nhấn <b>\"🔄 Kiểm tra thanh toán\"</b> bên dưới.</i>"
            )

            try:
                await call.message.delete()
            except Exception:
                pass

            await call.message.answer_photo(
                photo=qr_image_url,
                caption=caption,
                parse_mode="HTML",
                reply_markup=payment_menu(pay_url)
            )

        elif call.data == "pay_cryptopay":
            if not EnvKeys.CRYPTO_PAY_TOKEN:
                await call.answer(localize("payments.not_configured"), show_alert=True)
                return

            try:
                crypto = CryptoPayAPI()
                invoice = await crypto.create_invoice(
                    amount=float(amount_dec),
                    expires_in=ttl_seconds,
                    currency=payment_request.currency,
                    accepted_assets="TON,USDT,BTC,ETH",
                    payload=str(call.from_user.id),
                )
            except CryptoPayAPIError as e:
                await log_audit("cryptopay_error", level="ERROR", user_id=call.from_user.id, resource_type="Payment", details=f"[{e.code}] {e.name}")
                await call.answer(localize("payments.crypto.api_error", error=e.name), show_alert=True)
                return
            except Exception as e:
                await log_audit("cryptopay_invoice_fail", level="ERROR", user_id=call.from_user.id, resource_type="Payment", details=str(e))
                await call.answer(localize("payments.crypto.create_fail", error=str(e)), show_alert=True)
                return

            pay_url = invoice.get("mini_app_invoice_url")
            invoice_id = invoice.get("invoice_id")

            await create_pending_payment(
                provider="cryptopay",
                external_id=str(invoice_id),
                user_id=call.from_user.id,
                amount=int(amount_dec),
                currency=payment_request.currency,
            )

            await state.update_data(invoice_id=invoice_id, payment_type="cryptopay")

            await call.message.edit_text(
                localize("payments.invoice.summary",
                         amount=int(amount_dec),
                         minutes=int(ttl_seconds / 60),
                         button=localize("btn.check_payment"),
                         currency=payment_request.currency),
                reply_markup=payment_menu(pay_url)
            )

        elif call.data == "pay_stars":
            if EnvKeys.STARS_PER_VALUE > 0:
                try:
                    await send_stars_invoice(
                        bot=call.message.bot,
                        chat_id=call.from_user.id,
                        amount=int(amount_dec),
                    )
                except Exception as e:
                    await log_audit("stars_invoice_fail", level="ERROR", user_id=call.from_user.id, resource_type="Payment", details=str(e))
                    await call.answer(localize("payments.stars.create_fail", error=str(e)), show_alert=True)
                    return
                await state.clear()
            else:
                await call.answer(localize("payments.not_configured"), show_alert=True)
                return

        elif call.data == "pay_fiat":
            if not EnvKeys.TELEGRAM_PROVIDER_TOKEN:
                await call.answer(localize("payments.not_configured"), show_alert=True)
                return

            try:
                await send_fiat_invoice(
                    bot=call.message.bot,
                    chat_id=call.from_user.id,
                    amount=int(amount_dec),
                )
            except Exception as e:
                await log_audit("fiat_invoice_fail", level="ERROR", user_id=call.from_user.id, resource_type="Payment", details=str(e))
                await call.answer(localize("payments.fiat.create_fail", error=str(e)), show_alert=True)
                return
            await state.clear()

    except Exception as e:
        logger.error(f"Payment processing error: {e}")
        await state.clear()
        await call.answer(localize("errors.something_wrong"), show_alert=True)


@router.callback_query(F.data == "check")
async def checking_payment(call: CallbackQuery, state: FSMContext):
    """
    Check CryptoPay invoice status and credit balance if paid.
    """
    user_id = call.from_user.id
    data = await state.get_data()
    payment_type = data.get("payment_type")

    if not payment_type:
        await call.answer(localize("payments.no_active_invoice"), show_alert=True)
        return

    if payment_type == "payos":
        invoice_id = data.get("invoice_id")
        if not invoice_id:
            await call.answer(localize("payments.invoice_not_found"), show_alert=True)
            await state.clear()
            return

        try:
            payos = PayOSAPI()
            info = await payos.get_payment_link_information(invoice_id)
        except PayOSAPIError as e:
            await log_audit("payos_check_error", level="ERROR", user_id=user_id, resource_type="Payment", details=f"[{e.code}] {e.desc}")
            await call.answer(localize("payments.payos.api_error", error=e.desc), show_alert=True)
            return
        except Exception as e:
            await log_audit("payos_get_fail", level="ERROR", user_id=user_id, resource_type="Payment", details=str(e))
            await call.answer(localize("payments.crypto.check_fail", error=str(e)), show_alert=True)
            return

        status = info.get("status")
        if status == "PAID":
            balance_amount = Decimal(str(info.get("amountPaid") or info.get("amount", "0"))).quantize(Decimal("0.01"))

            if balance_amount <= 0:
                await call.answer(localize("payments.unable_determine_amount"), show_alert=True)
                return

            success, error_msg = await process_payment_with_referral(
                user_id=user_id,
                amount=balance_amount,
                provider="payos",
                external_id=str(invoice_id),
                referral_percent=EnvKeys.REFERRAL_PERCENT
            )

            if not success:
                if error_msg == "already_processed":
                    await call.answer(localize("payments.already_processed"), show_alert=True)
                else:
                    await call.answer(localize("errors.general_error", e=error_msg), show_alert=True)
                return

            metrics = get_metrics()
            if metrics:
                metrics.track_event("payment", user_id, {"amount": balance_amount, "provider": "payos"})

            await _notify_referrer_bonus(call.bot, user_id, balance_amount, call.from_user.first_name, call.from_user.id)

            success_msg = localize("payments.topped_simple",
                                   amount=balance_amount,
                                   currency=EnvKeys.PAY_CURRENCY)

            await call.answer(success_msg, show_alert=True)

            if call.message.text is not None:
                await call.message.edit_text(success_msg, reply_markup=back('profile'))
            else:
                try:
                    await call.message.delete()
                except Exception:
                    pass
                await call.message.answer(success_msg, reply_markup=back('profile'))
            await state.clear()

            try:
                user_info = await call.bot.get_chat(user_id)
                await log_audit(
                    "balance_replenish",
                    user_id=user_id,
                    resource_type="Payment",
                    details=f"name={user_info.first_name}, amount={balance_amount} {EnvKeys.PAY_CURRENCY}, provider=payos",
                )
            except (TelegramBadRequest, TelegramForbiddenError) as e:
                await log_audit("balance_replenish", level="ERROR", user_id=user_id, resource_type="Payment", details=f"log_failed: {e}")

        elif status in ["PENDING", "PROCESSING"]:
            await call.answer(localize("payments.not_paid_yet"), show_alert=True)
        else:
            await call.answer(localize("payments.expired"), show_alert=True)

    elif payment_type == "cryptopay":
        invoice_id = data.get("invoice_id")
        if not invoice_id:
            await call.answer(localize("payments.invoice_not_found"), show_alert=True)
            await state.clear()
            return

        try:
            crypto = CryptoPayAPI()
            info = await crypto.get_invoice(invoice_id)
        except CryptoPayAPIError as e:
            await log_audit("cryptopay_check_error", level="ERROR", user_id=user_id, resource_type="Payment", details=f"[{e.code}] {e.name}")
            await call.answer(localize("payments.crypto.api_error", error=e.name), show_alert=True)
            return
        except Exception as e:
            await log_audit("cryptopay_get_fail", level="ERROR", user_id=user_id, resource_type="Payment", details=str(e))
            await call.answer(localize("payments.crypto.check_fail", error=str(e)), show_alert=True)
            return

        status = info.get("status")
        if status == "paid":
            balance_amount = Decimal(str(info.get("amount", "0"))).quantize(Decimal("0.01"))

            if balance_amount <= 0:
                await call.answer(localize("payments.unable_determine_amount"), show_alert=True)
                return

            # Use transactional payment processing
            success, error_msg = await process_payment_with_referral(
                user_id=user_id,
                amount=balance_amount,
                provider="cryptopay",
                external_id=str(invoice_id),
                referral_percent=EnvKeys.REFERRAL_PERCENT
            )

            if not success:
                if error_msg == "already_processed":
                    await call.answer(localize("payments.already_processed"), show_alert=True)
                else:
                    await call.answer(localize("errors.general_error", e=error_msg), show_alert=True)
                return

            metrics = get_metrics()
            if metrics:
                metrics.track_event("payment", user_id, {"amount": balance_amount, "provider": "cryptopay"})

            # Send a notification to the referrer
            await _notify_referrer_bonus(call.bot, user_id, balance_amount, call.from_user.first_name, call.from_user.id)

            success_msg = localize("payments.topped_simple",
                                   amount=balance_amount,
                                   currency=EnvKeys.PAY_CURRENCY)

            await call.answer(success_msg, show_alert=True)

            if call.message.text is not None:
                await call.message.edit_text(success_msg, reply_markup=back('profile'))
            else:
                try:
                    await call.message.delete()
                except Exception:
                    pass
                await call.message.answer(success_msg, reply_markup=back('profile'))
            await state.clear()

            # Audit log
            try:
                user_info = await call.bot.get_chat(user_id)
                await log_audit(
                    "balance_replenish",
                    user_id=user_id,
                    resource_type="Payment",
                    details=f"name={user_info.first_name}, amount={balance_amount} {EnvKeys.PAY_CURRENCY}, provider=cryptopay",
                )
            except (TelegramBadRequest, TelegramForbiddenError) as e:
                await log_audit("balance_replenish", level="ERROR", user_id=user_id, resource_type="Payment", details=f"log_failed: {e}")

        elif status == "active":
            await call.answer(localize("payments.not_paid_yet"))
        else:
            await call.answer(localize("payments.expired"), show_alert=True)


@router.pre_checkout_query()
async def pre_checkout_handler(query: PreCheckoutQuery):
    """Validate the payment before Telegram processes it."""
    try:
        payload = json.loads(query.invoice_payload or "{}")
    except Exception:
        await query.answer(ok=False, error_message="Invalid payload")
        return

    amount = int(payload.get("amount", 0) or payload.get("amount_rub", 0))
    if amount <= 0:
        await query.answer(ok=False, error_message="Invalid amount")
        return

    if amount < int(EnvKeys.MIN_AMOUNT):
        await query.answer(ok=False, error_message="Amount below minimum")
        return

    if amount > int(EnvKeys.MAX_AMOUNT):
        await query.answer(ok=False, error_message="Amount exceeds maximum")
        return

    await query.answer(ok=True)


@router.message(F.successful_payment)
async def successful_payment_handler(message: Message):
    """
    Handle successful payment:
    - XTR (Stars): total_amount is ⭐. take CURRENCY from payload (amount) or convert ⭐ → CURRENCY.
    - Fiat: total_amount is minor units; divide by 100 (or 1 for JPY/KRW).
    """
    sp: SuccessfulPayment = message.successful_payment
    user_id = message.from_user.id

    payload = {}
    try:
        if sp.invoice_payload:
            payload = json.loads(sp.invoice_payload)
    except Exception:
        payload = {}

    amount = 0

    if sp.currency == "XTR":
        # Stars
        if "amount" in payload:
            amount = int(payload["amount"])
        else:
            amount = int(
                (Decimal(int(sp.total_amount)) / Decimal(str(EnvKeys.STARS_PER_VALUE)))
                .to_integral_value(rounding=ROUND_HALF_UP)
            )
    else:
        # Fiat
        currency = sp.currency.upper()
        multiplier = _minor_units_for(currency)
        amount = int(Decimal(sp.total_amount) / Decimal(multiplier))

    if amount <= 0:
        await message.answer(localize("payments.unable_determine_amount"), reply_markup=close())
        return

    # Idempotence
    provider = "telegram" if sp.currency != "XTR" else "stars"
    external_id = sp.telegram_payment_charge_id or sp.provider_payment_charge_id
    if not external_id:
        digest = hashlib.sha256(
            f"{provider}|{user_id}|{sp.currency}|{sp.total_amount}|{sp.invoice_payload or ''}".encode()
        ).hexdigest()
        external_id = f"{provider}:fallback:{digest[:32]}"
        logger.warning(
            "successful_payment without a charge id for user %s (%s %s); "
            "falling back to a derived idempotency key %s",
            user_id, sp.total_amount, sp.currency, external_id,
        )

    success, error_msg = await process_payment_with_referral(
        user_id=user_id,
        amount=Decimal(amount),
        provider=provider,
        external_id=external_id,
        referral_percent=EnvKeys.REFERRAL_PERCENT
    )

    if not success:
        if error_msg == "already_processed":
            await message.answer(localize("payments.already_processed"), reply_markup=close())
        else:
            await message.answer(localize("payments.processing_error"), reply_markup=close())
        return

    # Sending notification to referrer
    await _notify_referrer_bonus(message.bot, user_id, amount, message.from_user.first_name, message.from_user.id)

    metrics = get_metrics()
    if metrics:
        metrics.track_event("payment", user_id, {"amount": amount, "provider": provider})

    suffix = localize("payments.success_suffix.stars") if sp.currency == "XTR" else localize(
        "payments.success_suffix.tg")
    await message.answer(
        localize('payments.topped_with_suffix', amount=amount, suffix=suffix, currency=EnvKeys.PAY_CURRENCY),
        reply_markup=back('profile')
    )

    # audit log
    try:
        user_info = await message.bot.get_chat(user_id)
        await log_audit(
            "balance_replenish",
            user_id=user_id,
            resource_type="Payment",
            details=f"name={user_info.first_name}, amount={amount} {EnvKeys.PAY_CURRENCY}, provider={suffix}",
        )
    except (TelegramBadRequest, TelegramForbiddenError) as e:
        await log_audit("balance_replenish", level="ERROR", user_id=user_id, resource_type="Payment", details=f"log_failed: {e}")


@router.callback_query(F.data == "buy_item")
async def select_payment_source_for_buy(call: CallbackQuery, state: FSMContext):
    """Display payment source selection (Wallet balance or Top up) before purchasing."""
    data = await state.get_data()
    raw_item_name = data.get('csrf_item')

    if not raw_item_name:
        try:
            await call.answer(localize("middleware.security.invalid_csrf"), show_alert=True)
        except TelegramBadRequest:
            pass
        return

    from bot.database.methods.read import get_item_info, get_promo_code, check_user_cached
    from bot.database.methods.pricing import effective_price, apply_promo_discount
    from bot.keyboards.inline import simple_buttons

    item = await get_item_info(raw_item_name)
    if not item:
        await call.answer(localize("shop.item.not_found"), show_alert=True)
        return

    user_info = await check_user_cached(call.from_user.id)
    user_balance = Decimal(str(user_info.get('balance', 0))).quantize(Decimal("0.01"))

    base_price, on_sale, original_price = effective_price(item)
    item_price = base_price

    applied_promo = data.get('applied_promo')
    if applied_promo:
        promo = await get_promo_code(applied_promo)
        if promo and promo.get('discount_type') and promo.get('discount_value'):
            item_price = apply_promo_discount(base_price, promo['discount_type'], promo['discount_value'], 1)

    formatted_price = f"{int(item_price):,}".replace(",", ".")
    formatted_balance = f"{int(user_balance):,}".replace(",", ".")
    currency = EnvKeys.PAY_CURRENCY

    text = (
        f"💳 <b>CHỌN NGUỒN TIỀN THANH TOÁN</b>\n\n"
        f"📦 <b>Sản phẩm</b>: <b>{html_escape(item['name'])}</b>\n"
        f"💵 <b>Giá thanh toán</b>: <code>{formatted_price}</code> {currency}\n"
        f"💰 <b>Số dư ví hiện tại</b>: <code>{formatted_balance}</code> {currency}\n\n"
        f"Vui lòng chọn phương thức thanh toán bên dưới:"
    )

    buttons = [
        (f"💳 Trừ từ ví (Số dư: {formatted_balance} {currency})", "confirm_buy_wallet"),
        ("➕ Nạp số dư", "replenish_balance"),
        (localize("btn.back"), "back_to_item"),
    ]

    if call.message.text is not None:
        await call.message.edit_text(text, reply_markup=simple_buttons(buttons, per_row=1), parse_mode="HTML")
    else:
        try:
            await call.message.delete()
        except Exception:
            pass
        await call.message.answer(text, reply_markup=simple_buttons(buttons, per_row=1), parse_mode="HTML")


@router.callback_query(F.data == "confirm_buy_wallet")
async def confirm_buy_wallet_handler(call: CallbackQuery, state: FSMContext):
    """Processing the purchase of goods from wallet balance."""
    try:
        data = await state.get_data()
        raw_item_name = data.get('csrf_item')

        if not raw_item_name:
            await call.answer(localize("middleware.security.invalid_csrf"), show_alert=True)
            return

        metrics = get_metrics()

        # Validation via Pydantic
        purchase_request = ItemPurchaseRequest(
            item_name=raw_item_name,
            user_id=call.from_user.id
        )

        if not is_safe_item_name(purchase_request.item_name):
            await call.answer(
                localize("errors.invalid_item_name"),
                show_alert=True
            )
            await log_audit("suspicious_item_name", level="WARNING", user_id=call.from_user.id, resource_type="Item", details=raw_item_name)
            return

        try:
            user_id = validate_telegram_id(call.from_user.id)
        except ValueError:
            await call.answer(localize("errors.invalid_user"), show_alert=True)
            return

        await call.answer(localize("shop.purchase.processing"))

        promo_code = data.get('applied_promo')

        success, message, purchase_data = await buy_item_transaction(
            user_id,
            purchase_request.item_name,
            promo_code=promo_code,
        )

        if not success:
            error_messages = {
                "user_not_found": "shop.purchase.fail.user_not_found",
                "item_not_found": "shop.item.not_found",
                "insufficient_funds": "shop.insufficient_funds",
                "out_of_stock": "shop.out_of_stock"
            }

            error_text = localize(
                error_messages.get(message, "shop.purchase.fail.general"),
                message=message
            )

            from bot.keyboards.inline import simple_buttons
            fail_buttons = [
                ("➕ Nạp số dư", "replenish_balance"),
                (localize("btn.back"), "back_to_item"),
            ]

            if call.message.text is not None:
                await call.message.edit_text(
                    error_text,
                    reply_markup=simple_buttons(fail_buttons, per_row=1)
                )
            else:
                try:
                    await call.message.delete()
                except Exception:
                    pass
                await call.message.answer(
                    error_text,
                    reply_markup=simple_buttons(fail_buttons, per_row=1)
                )

            if message not in error_messages:
                await log_audit("purchase_error", level="ERROR", user_id=user_id, resource_type="Item", resource_id=purchase_request.item_name, details=message)
            return

        if metrics:
            metrics.track_event("purchase", call.from_user.id, {
                "item": purchase_request.item_name,
                "price": purchase_data['price']
            })
            metrics.track_conversion("purchase_funnel", "purchase", call.from_user.id)

        safe_value = sanitize_html(purchase_data['value'])
        username = call.from_user.username or call.from_user.first_name

        from bot.keyboards.inline import simple_buttons
        buttons = [
            (f"📦 {purchase_data['item_name']}", f"bought-item:{purchase_data['bought_id']}:back_to_item"),
            (localize("btn.back"), "back_to_item"),
        ]

        if call.message.text is not None:
            await call.message.edit_text(
                localize(
                    'shop.purchase.receipt',
                    item_name=purchase_data['item_name'],
                    price=purchase_data['price'],
                    unique_id=purchase_data['unique_id'],
                    datetime=purchase_data['bought_datetime'],
                    username=username,
                    user_id=call.from_user.id,
                    value=safe_value,
                    currency=EnvKeys.PAY_CURRENCY,
                ),
                parse_mode='HTML',
                reply_markup=simple_buttons(buttons),
            )
        else:
            try:
                await call.message.delete()
            except Exception:
                pass
            await call.message.answer(
                localize(
                    'shop.purchase.receipt',
                    item_name=purchase_data['item_name'],
                    price=purchase_data['price'],
                    unique_id=purchase_data['unique_id'],
                    datetime=purchase_data['bought_datetime'],
                    username=username,
                    user_id=call.from_user.id,
                    value=safe_value,
                    currency=EnvKeys.PAY_CURRENCY,
                ),
                parse_mode='HTML',
                reply_markup=simple_buttons(buttons),
            )

        try:
            user_info = await call.bot.get_chat(user_id)
            await log_audit(
                "purchase",
                user_id=user_id,
                resource_type="Item",
                resource_id=purchase_request.item_name[:100],
                details=f"name={user_info.first_name[:50]}, price={purchase_data['price']} {EnvKeys.PAY_CURRENCY}, unique_id={purchase_data['unique_id']}",
            )
        except Exception as e:
            await log_audit("purchase", level="ERROR", user_id=user_id, resource_type="Item", details=f"log_failed: {e}")

    except Exception as e:
        logger.error(f"Critical error in purchase handler: {e}")
        await call.answer(
            localize("errors.something_wrong"),
            show_alert=True
        )
