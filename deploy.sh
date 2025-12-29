#!/bin/bash

# --- CONFIGURACIÓN ---
# Reemplaza con tus datos reales si no quieres usar variables de entorno
SSH_USER="${SSH_USER:-webmaster}"
SSH_HOST="${SSH_HOST:-esd-hosting}"
SSH_PORT="${SSH_PORT:-22}"
DEPLOY_PATH="${DEPLOY_PATH_PORTAL:-/home/webmaster/web/portal.enitysky.dev/public_html}"
# ----------------------

echo "🚀 Iniciando despliegue local..."

# 1. Instalar dependencias de PHP
echo "📦 Instalando dependencias de PHP..."
composer install --no-dev --optimize-autoloader

# 2. Instalar dependencias de Node
echo "📦 Instalando dependencias de Node..."
npm ci

# 3. Compilar assets (Webpack Encore)
echo "🎨 Compilando assets de temas y módulos..."
npm run build

# 4. Sincronizar vía Rsync
echo "📤 Sincronizando archivos con el servidor..."
rsync -avzr --delete \
    --exclude='.git/' \
    --exclude='.github/' \
    --exclude='.editorconfig' \
    --exclude='.php-cs-fixer.dist.php' \
    --exclude='phpstan.neon' \
    --exclude='phpunit.xml.dist' \
    --exclude='tests/' \
    --exclude='tests-legacy/' \
    --exclude='Dockerfile' \
    --exclude='rector.php' \
    --exclude='src/config.php' \
    --exclude='src/data/cache/' \
    --exclude='src/data/log/' \
    --exclude='src/data/uploads/' \
    -e "ssh -p $SSH_PORT" \
    ./ $SSH_USER@$SSH_HOST:$DEPLOY_PATH

# 5. Permisos Post-despliegue
echo "🔑 Ajustando permisos en el servidor..."
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "cd $DEPLOY_PATH && mkdir -p src/data/cache src/data/log src/data/uploads && chmod -R 775 src/data"

echo "✅ ¡Despliegue completado con éxito!"
