from .main import router as main_router
from .language import router as language_router
from .content_pages import router as content_pages_router
from .balance_and_payment import router as balance_and_payment_router
from .shop_and_goods import router as shop_and_goods_router
from .referral_system import router as referral_system_router
from .cart import router as cart_router
from .gacha import router as gacha_router
from .media_capture import router as media_capture_router
from .entertainment import router as entertainment_router

from aiogram import Router

router = Router()
router.include_router(main_router)
router.include_router(language_router)
router.include_router(content_pages_router)
router.include_router(balance_and_payment_router)
router.include_router(shop_and_goods_router)
router.include_router(referral_system_router)
router.include_router(cart_router)
router.include_router(gacha_router)
router.include_router(media_capture_router)
router.include_router(entertainment_router)
