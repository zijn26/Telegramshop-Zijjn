from aiogram import Router, F
from aiogram.types import CallbackQuery
from aiogram.fsm.context import FSMContext
from aiogram.exceptions import TelegramBadRequest

from decimal import Decimal
from bot.database.methods.read import check_user_cached
from bot.database.methods.gacha import (
    get_gacha_settings,
    get_active_gacha_items,
    spin_gacha_for_user,
    get_user_gacha_wins,
)
from bot.keyboards.inline import gacha_keyboard, back
from bot.misc import EnvKeys
from bot.misc.button_registry import register_system_button, get_system_button_text

router = Router()


@register_system_button(key="gacha", name="🎰 Vòng quay Gacha (Gacha System)", help_text="Trang chính vòng quay may mắn Gacha.")
@router.callback_query(F.data == "gacha_main")
async def gacha_main_handler(call: CallbackQuery, state: FSMContext):
    """Show Gacha main screen."""
    user_id = call.from_user.id
    user_info = await check_user_cached(user_id)
    balance = float(user_info.get("balance", 0)) if user_info else 0.0

    settings = await get_gacha_settings()
    if not settings.is_active:
        await call.answer("❌ Hệ thống Gacha hiện đang tạm đóng. Vui lòng quay lại sau!", show_alert=True)
        return

    spin_price = float(settings.spin_price)
    currency = getattr(EnvKeys, "PAY_CURRENCY", "VND") or "VND"

    custom_text = await get_system_button_text("gacha")
    if custom_text:
        header_text = custom_text
    else:
        header_text = (
            f"<b>{settings.title}</b>\n\n"
            f"{settings.description or 'Thử vận may ngay hôm nay với nhiều phần quà hấp dẫn!'}\n\n"
            f"💰 Số dư tài khoản: <b>{balance:,.0f} {currency}</b>\n"
            f"🎯 Giá lượt quay: <b>{spin_price:,.0f} {currency} / lượt</b>"
        )

    markup = gacha_keyboard(user_balance=balance, spin_price=spin_price)

    if call.message.text is not None:
        try:
            await call.message.edit_text(header_text, reply_markup=markup, parse_mode="HTML")
        except TelegramBadRequest as e:
            if "message is not modified" not in str(e):
                raise
    else:
        try:
            await call.message.delete()
        except Exception:
            pass
        await call.message.answer(header_text, reply_markup=markup, parse_mode="HTML")
    await state.clear()


@router.callback_query(F.data == "gacha_spin")
async def gacha_spin_handler(call: CallbackQuery, state: FSMContext):
    """Execute a Gacha spin."""
    user_id = call.from_user.id
    success, message, won_item, reward_detail = await spin_gacha_for_user(user_id)

    user_info = await check_user_cached(user_id)
    balance = float(user_info.get("balance", 0)) if user_info else 0.0
    settings = await get_gacha_settings()
    spin_price = float(settings.spin_price)
    currency = getattr(EnvKeys, "PAY_CURRENCY", "VND") or "VND"

    markup = gacha_keyboard(user_balance=balance, spin_price=spin_price)

    if not success:
        await call.answer(message.replace("<b>", "").replace("</b>", ""), show_alert=True)
        return

    # Winning message layout
    image_url = won_item.image_url if (won_item and won_item.image_url) else None
    
    result_text = (
        f"🎉 <b>CHÚC MỪNG BẠN ĐÃ QUAY THÀNH CÔNG!</b> 🎉\n\n"
        f"🎁 Phần thưởng: <b>{won_item.name}</b>\n"
        f"ℹ️ Chi tiết: <b>{reward_detail}</b>\n\n"
        f"💰 Số dư còn lại: <b>{balance:,.0f} {currency}</b>"
    )

    if call.message.text is not None:
        try:
            await call.message.edit_text(result_text, reply_markup=markup, parse_mode="HTML")
        except TelegramBadRequest as e:
            if "message is not modified" not in str(e):
                raise
    else:
        try:
            await call.message.delete()
        except Exception:
            pass
        await call.message.answer(result_text, reply_markup=markup, parse_mode="HTML")
    await state.clear()


@router.callback_query(F.data == "gacha_my_wins")
async def gacha_my_wins_handler(call: CallbackQuery, state: FSMContext):
    """Display items won by current user."""
    user_id = call.from_user.id
    wins = await get_user_gacha_wins(user_id, limit=25)

    if not wins:
        text = "🎁 <b>LỊCH SỬ TRÚNG GACHA</b>\n\n<i>Bạn chưa quay trúng phần thưởng nào. Hãy quay ngay để nhận quà!</i>"
    else:
        lines = ["🎁 <b>DANH SÁCH VẬT PHẨM BẠN ĐÃ TRÚNG:</b>\n"]
        for idx, win in enumerate(wins, 1):
            time_str = win.won_at.strftime("%H:%M %d/%m/%Y") if win.won_at else ""
            lines.append(f"{idx}. <b>{win.item_name}</b> ({time_str})")
            if win.reward_details:
                lines.append(f"   └ <i>{win.reward_details}</i>")
        text = "\n".join(lines)

    markup = back("gacha_main")
    if call.message.text is not None:
        await call.message.edit_text(text, reply_markup=markup, parse_mode="HTML")
    else:
        try:
            await call.message.delete()
        except Exception:
            pass
        await call.message.answer(text, reply_markup=markup, parse_mode="HTML")
    await state.clear()


@router.callback_query(F.data == "gacha_items_list")
async def gacha_items_list_handler(call: CallbackQuery, state: FSMContext):
    """Display active Gacha items and their drop rates."""
    items = await get_active_gacha_items()
    settings = await get_gacha_settings()

    if not items:
        text = "📋 <b>DANH SÁCH VẬT PHẨM GACHA</b>\n\n<i>Hiện chưa có vật phẩm nào trong vòng quay.</i>"
    else:
        lines = [f"📋 <b>DANH SÁCH VẬT PHẨM & TỶ LỆ TRÚNG ({settings.title}):</b>\n"]
        for idx, item in enumerate(items, 1):
            stock_str = "Vô hạn" if item.stock_quantity == -1 else f"Còn {item.stock_quantity}"
            lines.append(f"{idx}. <b>{item.name}</b> — Tỷ lệ: <code>{item.drop_rate}%</code> ({stock_str})")
            if item.description:
                lines.append(f"   └ <i>{item.description}</i>")
        text = "\n".join(lines)

    markup = back("gacha_main")
    if call.message.text is not None:
        await call.message.edit_text(text, reply_markup=markup, parse_mode="HTML")
    else:
        try:
            await call.message.delete()
        except Exception:
            pass
        await call.message.answer(text, reply_markup=markup, parse_mode="HTML")
    await state.clear()
