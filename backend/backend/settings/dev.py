import os
from .base import *

# Development settings
DEBUG = True
ALLOWED_HOSTS = ['*']

# Database configuration - FIXED
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'ecommerce_db',           # ← DATABASE NAME (not user)
        'USER': 'ecommerce_user',         # ← USER NAME
        'PASSWORD': 'ecommerce_password', # ← PASSWORD
        'HOST': 'db',                     # ← Docker service name
        'PORT': '5432',                   # ← Port
    }
}

# Add debug_toolbar only if not already present
if 'debug_toolbar' not in INSTALLED_APPS:
    INSTALLED_APPS.append('debug_toolbar')
    INSTALLED_APPS.append('django_extensions')

if 'debug_toolbar.middleware.DebugToolbarMiddleware' not in MIDDLEWARE:
    MIDDLEWARE.insert(0, 'debug_toolbar.middleware.DebugToolbarMiddleware')

INTERNAL_IPS = ['127.0.0.1', 'localhost']

# CORS settings
CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True

# Email for development
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
