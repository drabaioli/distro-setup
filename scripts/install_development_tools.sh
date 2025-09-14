#!/bin/bash

# Install development tools and build essentials
sudo apt install -y git cmake build-essential wget

# Download and install p4merge
echo "Installing p4merge..."
cd /tmp
wget https://filehost.perforce.com/perforce/r23.2/bin.linux26x86_64/p4v.tgz
tar -xzf p4v.tgz
sudo mkdir -p /opt/p4v
sudo mv p4v-*/* /opt/p4v/
rm -rf p4v-* p4v.tgz

# Add p4merge to PATH for all users
echo 'export PATH="/opt/p4v/bin:$PATH"' | sudo tee /etc/profile.d/p4v.sh > /dev/null
sudo chmod +x /etc/profile.d/p4v.sh

# Also add to current user's .bashrc for immediate availability
cat <<EOT >> ~/.bashrc

# Add p4merge to PATH
export PATH="/opt/p4v/bin:$PATH"
EOT

# Move to the dir where this script is
base_path=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
cd "$base_path"

cp ../data/gitconfig ~/.gitconfig

echo "Development tools installed successfully!"
