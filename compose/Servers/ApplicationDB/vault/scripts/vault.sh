#!/bin/sh
set -e

/usr/local/bin/docker-entrypoint.sh "$@" &

export VAULT_ADDR=${VAULT_INTERNAL_ADDR}
export VAULT_TOKEN=${VAULT_DEV_ROOT_TOKEN_ID}

echo "⏳ Waiting for Vault to initialize..."

until vault status >/dev/null 2>&1; do
  sleep 1
done

sleep 3

until vault token lookup >/dev/null 2>&1; do
  echo "⏳ Waiting for Vault token to be ready..."
  sleep 2
done

echo "✅ Vault is ready, writing secrets..."

vault kv put secret/calcDbSecrets \
  spring.datasource.url=jdbc:mysql://mysql-calc:3306/calc \
  spring.datasource.username=calcUserDB \
  spring.datasource.password=123456

echo "✅ Vault secrets configured successfully!"

wait $!