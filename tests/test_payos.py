import pytest
from unittest.mock import AsyncMock, patch, MagicMock
from bot.misc.services.payos import PayOSAPI, PayOSAPIError
from bot.misc.env import EnvKeys


def test_payos_signature_creation():
    with patch.object(EnvKeys, "PAYOS_CHECKSUM_KEY", "test_checksum_key"):
        payos = PayOSAPI()
        data = {
            "amount": 10000,
            "cancelUrl": "https://example.com/cancel",
            "description": "Nap tien",
            "orderCode": 123456,
            "returnUrl": "https://example.com/return",
        }
        sig = payos.create_signature(data)
        assert isinstance(sig, str)
        assert len(sig) == 64  # HMAC-SHA256 hex digest length


def test_payos_webhook_signature_verification():
    with patch.object(EnvKeys, "PAYOS_CHECKSUM_KEY", "test_checksum_key"):
        payos = PayOSAPI()
        data = {
            "orderCode": 123456,
            "amount": 10000,
            "description": "Nap tien",
        }
        expected_sig = payos.create_signature(data)
        assert payos.verify_webhook_signature(data, expected_sig) is True
        assert payos.verify_webhook_signature(data, "invalid_sig") is False


@pytest.mark.asyncio
async def test_payos_create_payment_link_success():
    with patch.object(EnvKeys, "PAYOS_CLIENT_ID", "client123"), \
         patch.object(EnvKeys, "PAYOS_API_KEY", "api123"), \
         patch.object(EnvKeys, "PAYOS_CHECKSUM_KEY", "key123"):

        payos = PayOSAPI()

        mock_resp_data = {
            "code": "00",
            "desc": "success",
            "data": {
                "orderCode": 123456,
                "checkoutUrl": "https://pay.payos.vn/web/123456",
            }
        }

        mock_response = AsyncMock()
        mock_response.status = 200
        mock_response.json = AsyncMock(return_value=mock_resp_data)

        mock_session = MagicMock()
        mock_session.post.return_value.__aenter__.return_value = mock_response

        with patch.object(PayOSAPI, "_get_session", return_value=mock_session):
            res = await payos.create_payment_link(
                order_code=123456,
                amount=10000,
                description="Test payment",
                cancel_url="https://cancel.com",
                return_url="https://return.com"
            )

            assert res.get("orderCode") == 123456
            assert res.get("checkoutUrl") == "https://pay.payos.vn/web/123456"


@pytest.mark.asyncio
async def test_payos_get_payment_info_success():
    with patch.object(EnvKeys, "PAYOS_CLIENT_ID", "client123"), \
         patch.object(EnvKeys, "PAYOS_API_KEY", "api123"):

        payos = PayOSAPI()

        mock_resp_data = {
            "code": "00",
            "desc": "success",
            "data": {
                "orderCode": 123456,
                "amount": 10000,
                "status": "PAID",
            }
        }

        mock_response = AsyncMock()
        mock_response.status = 200
        mock_response.json = AsyncMock(return_value=mock_resp_data)

        mock_session = MagicMock()
        mock_session.get.return_value.__aenter__.return_value = mock_response

        with patch.object(PayOSAPI, "_get_session", return_value=mock_session):
            res = await payos.get_payment_link_information(123456)
            assert res.get("status") == "PAID"
            assert res.get("amount") == 10000
