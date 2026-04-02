#!/bin/bash

set -e

echo "Mise à jour des paquets..."
sudo apt update

echo "Installation des dépendances système..."
sudo apt install -y curl unzip python3-pip

echo "Installation de Packer..."
if ! command -v packer >/dev/null 2>&1; then
  curl -fsSL https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_amd64.zip -o packer.zip
  unzip -o packer.zip
  sudo mv packer /usr/local/bin/
  rm -f packer.zip
else
  echo "Packer est déjà installé."
fi

echo "Installation de K3d..."
if ! command -v k3d >/dev/null 2>&1; then
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else
  echo "K3d est déjà installé."
fi

echo "Installation des dépendances Python..."
pip3 install --user ansible kubernetes

echo "Installation de la collection Ansible kubernetes.core..."
ansible-galaxy collection install kubernetes.core

echo "Vérification des outils..."
packer version || true
k3d version || true
kubectl version --client || true
ansible --version || true

echo "Mise en place terminée."
