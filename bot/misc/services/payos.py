import hmac
import hashlib
import json
import logging
import aiohttp
from typing import Optional, Dict, Any

from bot.misc.env import EnvKeys

logger = logging.getLogger(__name__)


class PayOSAPIError(Exception):
    """Exception raised when PayOS API returns an error."""

    def __init__(self, code: str | int, desc: str, message: str = None):
        self.code = code
        self.desc = desc
        self.message = message or desc
        super().__init__(f"PayOS API Error [{code}]: {desc}")


class PayOSAPI:
    """Async client for PayOS Payment Gateway (VietQR)."""

    _timeout = aiohttp.ClientTimeout(total=30)
    _session: Optional[aiohttp.ClientSession] = None

    def __init__(self):
        self.client_id = EnvKeys.PAYOS_CLIENT_ID
        self.api_key = EnvKeys.PAYOS_API_KEY
        self.checksum_key = EnvKeys.PAYOS_CHECKSUM_KEY
        self.base_url = "https://api-merchant.payos.vn/v2"

    @classmethod
    def _get_session(cls) -> aiohttp.ClientSession:
        if cls._session is None or cls._session.closed:
            cls._session = aiohttp.ClientSession(timeout=cls._timeout)
        return cls._session

    @classmethod
    async def close_session(cls):
        if cls._session and not cls._session.closed:
            await cls._session.close()
            cls._session = None

    def create_signature(self, data: Dict[str, Any]) -> str:
        """
        Generate HMAC-SHA256 signature for a dictionary by sorting keys alphabetically.
        Format: key1=val1&key2=val2...
        """
        sorted_keys = sorted(data.keys())
        query_string_parts = []
        for k in sorted_keys:
            val = data[k]
            if val is None:
                continue
            if isinstance(val, (dict, list)):
                val_str = json.dumps(val, separators=(',', ':'), ensure_ascii=False)
            else:
                val_str = str(val)
            query_string_parts.append(f"{k}={val_str}")
        
        query_string = "&".join(query_string_parts)
        signature = hmac.new(
            self.checksum_key.encode('utf-8'),
            query_string.encode('utf-8'),
            hashlib.sha256
        ).hexdigest()
        return signature

    def verify_webhook_signature(self, webhook_data: Dict[str, Any], signature: str) -> bool:
        """
        Verify signature from PayOS Webhook payload data.
        """
        if not signature or not self.checksum_key:
            return False
        expected_sig = self.create_signature(webhook_data)
        return hmac.compare_digest(expected_sig.lower(), signature.lower())

    async def create_payment_link(
        self,
        order_code: int,
        amount: int,
        description: str,
        cancel_url: str,
        return_url: str,
        items: Optional[list] = None,
        buyer_name: Optional[str] = None,
        buyer_email: Optional[str] = None,
        buyer_phone: Optional[str] = None,
        buyer_address: Optional[str] = None,
        expired_at: Optional[int] = None,
    ) -> Dict[str, Any]:
        """
        Create PayOS payment link via POST /v2/payment-requests.
        """
        if not self.client_id or not self.api_key or not self.checksum_key:
            raise PayOSAPIError("NOT_CONFIGURED", "PayOS environment variables (PAYOS_CLIENT_ID, PAYOS_API_KEY, PAYOS_CHECKSUM_KEY) are not set.")

        # Ensure description is max 25 characters
        clean_desc = str(description)[:25]

        data_to_sign = {
            "amount": int(amount),
            "cancelUrl": cancel_url,
            "description": clean_desc,
            "orderCode": int(order_code),
            "returnUrl": return_url,
        }

        signature = self.create_signature(data_to_sign)

        payload = {
            "orderCode": int(order_code),
            "amount": int(amount),
            "description": clean_desc,
            "cancelUrl": cancel_url,
            "returnUrl": return_url,
            "signature": signature,
        }

        if items:
            payload["items"] = items
        if buyer_name:
            payload["buyerName"] = buyer_name
        if buyer_email:
            payload["buyerEmail"] = buyer_email
        if buyer_phone:
            payload["buyerPhone"] = buyer_phone
        if buyer_address:
            payload["buyerAddress"] = buyer_address
        if expired_at:
            payload["expiredAt"] = expired_at

        headers = {
            "x-client-id": self.client_id,
            "x-api-key": self.api_key,
            "Content-Type": "application/json",
        }

        session = self._get_session()
        try:
            async with session.post(f"{self.base_url}/payment-requests", json=payload, headers=headers) as resp:
                if resp.status == 429:
                    raise PayOSAPIError(429, "PayOS API rate limit exceeded (HTTP 429).")
                
                content_type = ""
                if hasattr(resp, "headers") and resp.headers and hasattr(resp.headers, "get"):
                    content_type = str(resp.headers.get("Content-Type", "") or "")

                if not content_type or "application/json" in content_type or "json" in content_type:
                    data = await resp.json()
                else:
                    text_body = await resp.text()
                    try:
                        data = json.loads(text_body)
                    except Exception:
                        raise PayOSAPIError(resp.status, f"PayOS API returned HTTP {resp.status} (non-JSON response).")

                if resp.status != 200 or data.get("code") != "00":
                    code = data.get("code", str(resp.status))
                    desc = data.get("desc", "Failed to create payment link")
                    raise PayOSAPIError(code, desc)

                return data.get("data", {})
        except PayOSAPIError:
            raise
        except Exception as e:
            logger.error(f"Error calling PayOS create_payment_link: {e}")
            raise PayOSAPIError("REQUEST_ERROR", str(e))

    async def get_payment_link_information(self, order_code: int | str) -> Dict[str, Any]:
        """
        Get PayOS payment status via GET /v2/payment-requests/{orderCode}.
        """
        if not self.client_id or not self.api_key:
            raise PayOSAPIError("NOT_CONFIGURED", "PayOS environment variables are not set.")

        headers = {
            "x-client-id": self.client_id,
            "x-api-key": self.api_key,
        }

        session = self._get_session()
        try:
            async with session.get(f"{self.base_url}/payment-requests/{order_code}", headers=headers) as resp:
                if resp.status == 429:
                    raise PayOSAPIError(429, "PayOS API rate limit exceeded (HTTP 429).")

                content_type = ""
                if hasattr(resp, "headers") and resp.headers and hasattr(resp.headers, "get"):
                    content_type = str(resp.headers.get("Content-Type", "") or "")

                if not content_type or "application/json" in content_type or "json" in content_type:
                    data = await resp.json()
                else:
                    text_body = await resp.text()
                    try:
                        data = json.loads(text_body)
                    except Exception:
                        raise PayOSAPIError(resp.status, f"PayOS API returned HTTP {resp.status} (non-JSON response).")

                if resp.status != 200 or data.get("code") != "00":
                    code = data.get("code", str(resp.status))
                    desc = data.get("desc", "Failed to fetch payment information")
                    raise PayOSAPIError(code, desc)

                return data.get("data", {})
        except PayOSAPIError:
            raise
        except Exception as e:
            logger.error(f"Error calling PayOS get_payment_link_information: {e}")
            raise PayOSAPIError("REQUEST_ERROR", str(e))
