#!/bin/bash

echo "🔍 Geth kontrol ediliyor..."
GETH_SYNC=$(curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  http://localhost:8545 | grep '"result":false')

if [[ $GETH_SYNC != "" ]]; then
  echo "✔ Geth senkronize oldu."
else
  echo "⏳ Geth henüz senkronize olmadı."
fi

echo ""
echo "🔍 Prysm kontrol ediliyor..."
PRYSM_SYNC=$(curl -s http://localhost:3500/eth/v1/node/syncing | grep '"is_syncing":false')

if [[ $PRYSM_SYNC != "" ]]; then
  echo "✔ Prysm senkronize oldu."
else
  echo "⏳ Prysm henüz senkronize olmadı."
fi
