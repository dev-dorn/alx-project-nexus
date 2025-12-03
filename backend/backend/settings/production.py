from .base import *
import dj_database_url
import os

# Import the ImproperlyConfigured exception
from django.core.exceptions import ImproperlyConfigured

# Production settings
DEBUG = False
SECRET_KEY = os.environ.get('SECRET_KEY')
if not SECRET_KEY:
    raise ImproperlyConfigured(
        "The SECRET_KEY environment variable is missing or empty. "
        "Set SECRET_KEY in your Render/hosting dashboard (do NOT commit it to source)."
    )

ALLOWED_HOSTS = [
    '.onrender.com',
    'localhost',
]

# Database from environment
DATABASES = {
    'default': dj_database_url.config(
        default=os.environ.get('DATABASE_URL'),
        conn_max_age=600,
        ssl_require=True,
    )
}

# Security settings
SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
X_FRAME_OPTIONS = 'DENY'
