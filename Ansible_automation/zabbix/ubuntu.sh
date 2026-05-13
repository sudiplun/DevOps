#!/bin/bash

set -e

# --- Prompt for hostname ---
read -rp "Enter Zabbix Agent Hostname: " ZABBIX_HOSTNAME

# --- Variables (from your playbook) ---
ZABBIX_SERVER_ACTIVE="45.115.217.242"
ZABBIX_TIMEOUT=30
ZABBIX_START_AGENTS=0

# --- Install prerequisites ---
echo "[*] Installing prerequisites..."
sudo apt update
sudo apt install -y wget gnupg

# --- Download and install Zabbix repo package ---
echo "[*] Downloading Zabbix repository package..."
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb

echo "[*] Installing Zabbix repository..."
sudo dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb

# --- Update package list ---
echo "[*] Updating package list..."
sudo apt update

# --- Install Zabbix agent ---
echo "[*] Installing Zabbix agent..."
sudo apt install -y zabbix-agent

# --- Configure Zabbix agent ---
CONFIG_FILE="/etc/zabbix/zabbix_agentd.conf"

echo "[*] Configuring Zabbix agent..."

sudo sed -i "s/^Hostname=.*/Hostname=${ZABBIX_HOSTNAME}/" $CONFIG_FILE
sudo sed -i "s/^ServerActive=.*/ServerActive=${ZABBIX_SERVER_ACTIVE}/" $CONFIG_FILE
sudo sed -i "s/^# StartAgents=.*/StartAgents=${ZABBIX_START_AGENTS}/" $CONFIG_FILE
sudo sed -i "s/^# Timeout=.*/Timeout=${ZABBIX_TIMEOUT}/" $CONFIG_FILE

# Optional: clear Server if empty (your playbook uses empty list)
sudo sed -i "s/^Server=.*/Server=127.0.0.1/" $CONFIG_FILE

# --- Restart and enable service ---
echo "[*] Restarting Zabbix agent..."
sudo systemctl restart zabbix-agent
sudo systemctl enable zabbix-agent

echo "[✓] Zabbix agent installation completed."
