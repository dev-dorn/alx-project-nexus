#!/bin/bash
set -e

# Run database migrations
python manage.py migrate --noinput

# Collect static files
python manage.py collectstatic --noinput

# Start Gunicorn
exec gunicorn backend.wsgi:application --bind 0.0.0.0:8000

