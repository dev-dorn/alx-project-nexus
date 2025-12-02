#!/bin/bash

# Create .env files
echo "Setting up environment files..."

# Create root .env
cat > .env << EOF
COMPOSE_PROJECT_NAME=ecommerce
POSTGRES_DB=ecommerce_db
POSTGRES_USER=ecommerce_user
POSTGRES_PASSWORD=ecommerce_password
DATABASE_URL=postgresql://ecommerce_user:ecommerce_password@db:5432/ecommerce_db
REDIS_URL=redis://redis:6379/0
EOF

# Create backend .env
cat > backend/.env << EOF
DEBUG=True
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(50))")
DJANGO_SETTINGS_MODULE=backend.settings.development
ALLOWED_HOSTS=localhost,127.0.0.1,backend,frontend

DB_NAME=ecommerce_db
DB_USER=ecommerce_user
DB_PASSWORD=ecommerce_password
DB_HOST=db
DB_PORT=5432

REDIS_URL=redis://redis:6379/0
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://frontend:3000
CORS_ALLOW_ALL_ORIGINS=True
EOF

# Create frontend .env.local
cat > frontend/.env.local << EOF
NEXT_PUBLIC_API_URL=http://localhost:8000/api
NEXT_PUBLIC_APP_URL=http://localhost:3000
EOF

# Create frontend .env.docker for Docker
cat > frontend/.env.docker << EOF
NEXT_PUBLIC_API_URL=http://backend:8000/api
NEXT_PUBLIC_APP_URL=http://frontend:3000
EOF

echo "Environment files created!"
echo "Make sure to review and update the passwords in .env files."
