#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Ensure required environment variables are set
if [[ -z "$ARM_FREQ" || -z "$MINING_POOL" || -z "$WALLET_ADDRESS" ]]; then
    echo "Missing required environment variables. Please set ARM_FREQ, MINING_POOL, and WALLET_ADDRESS in .env."
    exit 1
fi

# Update system
sudo apt update && sudo apt upgrade -y

# Modify boot configuration
sudo bash -c "echo 'arm_freq=$ARM_FREQ' >> /boot/firmware/config.txt"

# Download and install mining software
curl -o install.sh -k https://raw.githubusercontent.com/Oink70/Android-Mining/main/install.sh
chmod +x install.sh
./install.sh

# Configure miner
cd ccminer || exit
cat <<EOF > config.json
{
    "wallet": "$WALLET_ADDRESS",
    "pool": "$MINING_POOL"
}
EOF

chmod +x start.sh

# Setup cron job for mining on boot
(crontab -l 2>/dev/null; echo "@reboot $(pwd)/start.sh") | crontab -

# Reboot system
sudo reboot now
