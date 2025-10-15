#!/bin/bash

ORANGE='\033[0;33m'
GREEN='\033[1;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

clear
echo -e "${CYAN}"
echo "██    ██ ███████ ██   ██ ██   ██"
echo "██    ██ ██      ██   ██ ██  ██ "
echo "██    ██ █████   ██   ██ █████  "
echo "██    ██ ██      ██   ██ ██  ██ "
echo "████████ ██      ███████ ██   ██"
echo -e "${RESET}"
echo -e "${GREEN}Script başlatılıyor: Ufuk tarafından hazırlanmıştır.${RESET}"
sleep 2

echo -e "${GREEN}1. Gerekli paketler kuruluyor...${RESET}"
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip -y

echo -e "${GREEN}2. Docker kuruluyor...${RESET}"
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /tmp/docker.gpg && sudo mv -f /tmp/docker.gpg /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl enable docker
sudo systemctl restart docker

echo -e "${GREEN}3. Dizinler oluşturuluyor...${RESET}"
mkdir -p /root/ethereum/execution
mkdir -p /root/ethereum/consensus

echo -e "${GREEN}4. JWT secret oluşturuluyor...${RESET}"
openssl rand -hex 32 > /root/ethereum/jwt.hex

echo -e "${GREEN}5. docker-compose.yml yazılıyor...${RESET}"
cat <<EOF > /root/ethereum/docker-compose.yml
version: "3.9"
services:
  geth:
    image: ethereum/client-go:latest
    container_name: geth
    restart: unless-stopped
    ports:
      - 30303:30303
      - 30303:30303/udp
      - 8545:8545
      - 8546:8546
      - 8551:8551
    volumes:
      - /root/ethereum/execution:/data
      - /root/ethereum/jwt.hex:/data/jwt.hex
    command:
      - --sepolia
      - --http
      - --http.api=eth,net,web3
      - --http.addr=0.0.0.0
      - --authrpc.addr=0.0.0.0
      - --authrpc.vhosts=*
      - --authrpc.jwtsecret=/data/jwt.hex
      - --authrpc.port=8551
      - --syncmode=snap
      - --datadir=/data
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  prysm:
    image: gcr.io/offchainlabs/prysm/beacon-chain:v6.1.2
    container_name: prysm
    restart: unless-stopped
    depends_on:
      - geth
    volumes:
      - /root/ethereum/consensus:/data
      - /root/ethereum/jwt.hex:/data/jwt.hex
    command:
      - --sepolia
      - --accept-terms-of-use
      - --datadir=/data
      - --execution-endpoint=http://geth:8551
      - --jwt-secret=/data/jwt.hex
      - --checkpoint-sync-url=https://sepolia.beaconstate.info
      - --genesis-beacon-api-url=https://sepolia.beaconstate.info
      - --subscribe-all-data-subnets
      - --rpc-host=0.0.0.0
      - --rpc-port=4000
      - --grpc-gateway-host=0.0.0.0
      - --grpc-gateway-port=3500
      - --disable-monitoring
      - --suggested-fee-recipient=0x2413a7B7c495407127cAa487721f3b8321CF65aA 
    ports:
      - 4000:4000
      - 3500:3500
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
EOF

echo -e "${GREEN}6. Node başlatılıyor...${RESET}"
cd /root/ethereum
docker compose up -d

echo -e "${GREEN}"
echo "✔ Node'lar şu anda senkronize olmaya başladı."
echo "⏳ Senkronizasyon birkaç saat sürebilir. Lütfen bu sürede node'ları durdurmayın."
echo ""
echo "🔗Adımları Takip Edin: https://github.com/UfukNode/ufuk-geth-prysm-installer"
echo ""
echo "⚠️ Aztec Sequencer başlatmadan önce hem Geth hem de Prysm node'larının TAM senkronize olduğundan emin olun."
echo -e "${RESET}"
