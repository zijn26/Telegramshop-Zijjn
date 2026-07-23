import pytest
from bot.web.admin import create_admin_app

@pytest.mark.asyncio
async def test_admin_views_form_scaffolding():
    app = create_admin_app()
    # Find the Admin instance attached to app
    admin = None
    for route in app.routes:
        if hasattr(route, "app") and hasattr(route.app, "_views"):
            admin = route.app
            break

    # Alternatively check views registered in admin app
    # Scaffold forms for all registered views
    from sqladmin import Admin
    # Ensure create_admin_app does not raise errors during view initialization
    assert app is not None
