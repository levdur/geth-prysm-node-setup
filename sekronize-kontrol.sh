#!/bin/bash

GREEN='\033[1;32m'
RED='\033[1;31m'
BLUE='\033[1;34m'
RESET='\033[0m'

echo -e "${BLUE}🔍 Geth ve Prysm senkronizasyon durumu kontrol ediliyor...${RESET}\n"

# GETH
GETH_SYNC=$(curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  http://localhost:8545 | grep '"result":false')

if [[ $GETH_SYNC != "" ]]; then
  echo -e "${GREEN}✔ Geth senkronize oldu.${RESET}"
else
  echo -e "${RED}✘ Geth henüz senkronize olmadı.${RESET}"
fi

# PRYSM
PRYSM_SYNC=$(curl -s http://localhost:3500/eth/v1/node/syncing | grep '"is_syncing":false')

if [[ $PRYSM_SYNC != "" ]]; then
  echo -e "${GREEN}✔ Prysm senkronize oldu.${RESET}"
else
  echo -e "${RED}✘ Prysm henüz senkronize olmadı.${RESET}"
fi
