FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        curl \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade pip

# Copy requirements first for better caching
COPY requirements /app/requirements/

# Install Python dependencies for PRODUCTION
RUN pip install --prefer-binary --default-timeout=100 --retries=5 --no-cache-dir -r requirements/base.txt
RUN pip install --prefer-binary --default-timeout=100 --retries=5 --no-cache-dir -r requirements/production.txt

# Add this line after pip install command if needed
RUN pip install --no-cache-dir celery==5.3.6 redis==5.0.1 flower==2.0.1

# Copy project code
COPY . /app/

# Create non-root user
RUN useradd --create-home --shell /bin/bash app \
    && chown -R app:app /app
USER app

# Django settings
ENV DJANGO_SETTINGS_MODULE=backend.settings.production

# Copy entrypoint script
COPY entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

# Expose port
EXPOSE 8000

# Use entrypoint script to handle migrations, collectstatic, then start Gunicorn
CMD ["/app/entrypoint.sh"]
