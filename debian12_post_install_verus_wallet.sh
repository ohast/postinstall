#!/bin/bash

# ========================================================================
# Debian 12 Post-Installation Script with Verus Wallet Setup
# ========================================================================
# 
# This script will:
# 1. Update your Debian 12 system
# 2. Install necessary dependencies and tools
# 3. Create a sudo user for system management
# 4. Set up desktop environment and RDP for remote access
# 5. Setup 2FA authentication for RDP using Google Authenticator (optional, can be done during installation)
#    (compatible with Aegis Authenticator)
# 6. Install the Verus wallet software
# 7. Configure basic security settings
#
# IMPORTANT: Read through all comments to understand what each section does
# 1. Update your Debian 12 system
# 2. Install necessary dependencies and tools
# 3. Set up desktop environment and RDP for remote access
# 4. Setup 2FA authentication for RDP using Google Authenticator (optional, can be done during installation)
#    (compatible with Aegis Authenticator)
# 5. Install the Verus wallet software
# 6. Configure basic security settings
#
# IMPORTANT: Read through all comments to understand what each section does
# ========================================================================

# Exit if any command fails - This will stop the script if any command returns an error
set -e

# Display a welcome message
echo "========================================================"
echo "   Debian 12 Post-Installation with Verus Wallet Setup"
echo "========================================================"
echo
echo "This script will set up your Debian 12 system and install Verus wallet."
echo "Please be patient as some steps may take several minutes."
echo

# ---------------------------------------------------------------------
# STEP 1: Configure System Repositories
# ---------------------------------------------------------------------
# This adds the official Debian repositories including non-free software
echo "STEP 1: Configuring system repositories..."

# Create a new sources.list file with all needed repositories
cat > /etc/apt/sources.list << REPOEOF
# Main Debian repositories
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb http://security.debian.org bookworm-security main contrib non-free non-free-firmware

# Backports repository for newer software versions
deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware
REPOEOF

echo "✓ Repositories configured."

# ---------------------------------------------------------------------
# STEP 2: Update System and Install Basic Tools
# ---------------------------------------------------------------------
# Updates all packages and installs essential tools
echo
echo "STEP 2: Updating system and installing essential tools..."

# Update package database
echo "• Updating package lists..."
apt update

# Upgrade all installed packages to their latest versions
echo "• Upgrading installed packages..."
apt upgrade -y

# Install essential system utilities and tools
echo "• Installing essential utilities and tools..."
apt install -y \
    curl \
    jq \
    wget \
    git \
    vim \
    htop \
    net-tools \
    sudo \
    unzip \
    apt-transport-https \
    ca-certificates \
    gnupg \
    neofetch \
    tmux \
    tree \
    rsync \
    ssh \
    ufw

echo "✓ System updated and essential tools installed."

# ---------------------------------------------------------------------
# STEP 2.5: Create Sudo User
# ---------------------------------------------------------------------
# Creates a new user with sudo privileges for system administration
echo
echo "STEP 2.5: Creating a sudo user..."

# Prompt for username and password
read -p "Enter username for new sudo user: " NEW_USERNAME

# Check if the username already exists
if id "$NEW_USERNAME" &>/dev/null; then
    echo "User $NEW_USERNAME already exists. Skipping user creation."
else
    # Create the new user
    echo "• Creating new user: $NEW_USERNAME"
    adduser $NEW_USERNAME
    
    # Add the user to the sudo group
    echo "• Adding $NEW_USERNAME to sudo group"
    usermod -aG sudo $NEW_USERNAME
    
    echo "✓ User $NEW_USERNAME created with sudo privileges."
fi

# Create .komodo directory for the new user
echo "• Setting up Verus directories for $NEW_USERNAME"
mkdir -p /home/$NEW_USERNAME/.komodo/VRSC
chown -R $NEW_USERNAME:$NEW_USERNAME /home/$NEW_USERNAME/.komodo

echo "✓ Sudo user created and configured."
# STEP 3: Set up Desktop Environment and RDP
# ---------------------------------------------------------------------
# Installs XFCE desktop and RDP server for remote connections
echo
echo "STEP 3: Setting up desktop environment and RDP..."

# Install XFCE desktop environment (lightweight and works well with RDP)
echo "• Installing XFCE desktop environment..."
apt install -y xfce4 xfce4-goodies

# Install xrdp for Remote Desktop Protocol support
echo "• Installing xrdp for remote desktop access..."
apt install -y xrdp

# Ensure xrdp service starts on boot
echo "• Enabling xrdp service..."
systemctl enable xrdp

# Configure xrdp to use xfce4
echo "• Configuring xrdp to use XFCE..."
echo "xfce4-session" > /etc/xrdp/xsession

# Restart xrdp to apply changes
echo "• Restarting xrdp service..."
systemctl restart xrdp

# Create .xsession file for all users
for DIR in /home/*; do
  USERNAME=$(basename "$DIR")
  echo "• Setting up XFCE for user: $USERNAME"
  echo "xfce4-session" > "/home/$USERNAME/.xsession"
  chown "$USERNAME":"$USERNAME" "/home/$USERNAME/.xsession"
done

echo "✓ Desktop environment and RDP setup complete."

# ---------------------------------------------------------------------
# STEP 4: Set up Two-Factor Authentication for RDP
# ---------------------------------------------------------------------
# Installs and configures Google Authenticator for 2FA (works with Aegis)
echo
echo "STEP 4: Setting up Two-Factor Authentication for RDP..."

# Install Google Authenticator PAM module
echo "• Installing Google Authenticator PAM module..."
apt install -y libpam-google-authenticator

# Configure PAM to use Google Authenticator for xrdp
echo "• Configuring PAM for xrdp with 2FA..."

# Add auth required pam_google_authenticator.so to PAM configuration for xrdp
if ! grep -q "pam_google_authenticator.so" /etc/pam.d/xrdp-sesman; then
  echo "auth required pam_google_authenticator.so" >> /etc/pam.d/xrdp-sesman
fi

# Configure security settings for xrdp
echo "• Hardening xrdp configuration..."
cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak
sed -i 's/security_layer=negotiate/security_layer=tls/g' /etc/xrdp/xrdp.ini
sed -i 's/crypt_level=high/crypt_level=high/g' /etc/xrdp/xrdp.ini
sed -i 's/bitmap_compression=true/bitmap_compression=false/g' /etc/xrdp/xrdp.ini
sed -i 's/max_bpp=32/max_bpp=24/g' /etc/xrdp/xrdp.ini

# Create a script to help users set up Google Authenticator
echo "• Creating setup script for Google Authenticator..."
cat > /usr/local/bin/setup-2fa << 'TWOFASCRIPT'
#!/bin/bash
echo "======================================"
echo "Google Authenticator Setup for RDP 2FA"
echo "======================================"
echo
echo "This will set up 2FA for your account."
echo "You'll need a TOTP app like Aegis Authenticator on your phone."
echo
echo "Press Enter to continue..."
read

# Run Google Authenticator setup with recommended settings
google-authenticator -t -d -f -r 3 -R 30 -w 3

echo
echo "======================================"
echo "Setup Complete!"
echo "======================================"
echo
echo "Scan the QR code above with your Aegis Authenticator app."
echo "Save the emergency scratch codes in a safe place."
echo
echo "When connecting via RDP, use your regular password AND"
echo "the verification code from your authenticator app."
echo

exit 0
TWOFASCRIPT

# Make the setup script executable
chmod +x /usr/local/bin/setup-2fa

# Prompt user if they want to set up 2FA now for the main user
echo
echo "Do you want to set up 2FA for user $NEW_USERNAME now? (y/n)"
echo "This will generate a QR code that you need to scan with your authenticator app."
read -p "> " SETUP_2FA_NOW

if [[ "$SETUP_2FA_NOW" == "y" || "$SETUP_2FA_NOW" == "Y" ]]; then
    echo "• Setting up 2FA for $NEW_USERNAME now..."
    echo "• You will need to scan a QR code with your authenticator app."
    echo "• IMPORTANT: Save the emergency scratch codes that will be displayed!"
    echo
    echo "Press Enter when you're ready to proceed..."
    read
    
    # Run the 2FA setup as the user
    su - $NEW_USERNAME -c "/usr/local/bin/setup-2fa"
    
    echo "✓ 2FA has been set up for $NEW_USERNAME."
else
    echo "• 2FA setup deferred. User $NEW_USERNAME can run 'setup-2fa' command later."
fi

echo "✓ Two-Factor Authentication setup complete."
echo "• Other users should run 'setup-2fa' to configure their authenticator app."

# ---------------------------------------------------------------------
# STEP 5: Install Development Tools and Dependencies for Verus
# ---------------------------------------------------------------------
# These tools are required to build and run the Verus software
echo
echo "STEP 5: Installing development tools and dependencies for Verus..."

# Install build tools and dependencies required for Verus
echo "• Installing build tools and dependencies..."
apt install -y \
    build-essential \
    pkg-config \
    libc6-dev \
    m4 \
    g++-multilib \
    autoconf \
    libtool \
    ncurses-dev \
    unzip \
    python3 \
    python3-pip \
    zlib1g-dev \
    bsdmainutils \
    automake \
    libgomp1 \
    libboost-all-dev \
    libsodium-dev \
    cmake \
    ntp

echo "✓ Development tools and dependencies installed."

# ---------------------------------------------------------------------
# STEP 6: Install Verus Wallet
# ---------------------------------------------------------------------
# Downloads and sets up the Verus wallet software
echo
echo "STEP 6: Installing Verus wallet..."

# Create directory for Verus software
echo "• Creating directory for Verus..."
mkdir -p /opt/verus

# Go to the Verus directory
cd /opt/verus

# Download the latest Verus binary release for Linux
echo "• Fetching information about latest Verus release..."
LATEST_RELEASE=$(curl -s https://api.github.com/repos/VerusCoin/VerusCoin/releases/latest | grep "browser_download_url.*Verus-CLI-Linux.*x86_64.tgz" | cut -d : -f 2,3 | tr -d \"\ )
echo "• Latest release URL: $LATEST_RELEASE"
wget $LATEST_RELEASE

# Extract the downloaded archive
echo "• Extracting Verus wallet files..."
tar -xvf $(ls Verus-CLI-Linux*.tgz)

# Remove the archive after extraction to save space
rm Verus-CLI-Linux*.tgz

# Create symbolic links to make Verus commands available system-wide
echo "• Creating symbolic links for Verus commands..."
ln -sf /opt/verus/verus-cli/verus /usr/local/bin/
ln -sf /opt/verus/verus-cli/verusd /usr/local/bin/

# Create a desktop shortcut for Verus
echo "• Creating desktop shortcut for Verus..."
cat > /usr/share/applications/verus.desktop << DESKEOF
[Desktop Entry]
Type=Application
Name=Verus Wallet
Comment=Verus Cryptocurrency Wallet
Exec=verus
Icon=/opt/verus/verus-cli/verus-logo.png
Terminal=true
Categories=Finance;
DESKEOF

echo "✓ Verus wallet installed successfully."

# ---------------------------------------------------------------------
# STEP 7: Configure Basic Security Settings
# ---------------------------------------------------------------------
# Sets up firewall and basic security measures
echo
echo "STEP 7: Configuring basic security settings..."

# Set up firewall
echo "• Setting up firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 3389/tcp  # For RDP
echo "y" | ufw enable

# Harden SSH configuration
echo "• Hardening SSH configuration..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh

echo "✓ Basic security settings configured."

# ---------------------------------------------------------------------
# STEP 8: Create Configuration for Verus
# ---------------------------------------------------------------------
# Sets up initial configuration for Verus
echo
echo "STEP 8: Creating initial configuration for Verus..."

# Create .komodo directory in root user's home
echo "• Creating configuration directory..."
mkdir -p /root/.komodo/VRSC

# Generate a random secure password for RPC
RPC_PASSWORD=$(openssl rand -hex 32)

# Create a simple verus.conf file with basic settings
echo "• Creating Verus configuration file..."
cat > /root/.komodo/VRSC/VRSC.conf << CONFEOF
# RPC configuration (for wallet and blockchain interaction)
rpcuser=verususer        # This is a username for RPC connections (you can change it)
rpcpassword=$RPC_PASSWORD  # Auto-generated secure password for RPC connections
rpcallowip=127.0.0.1     # Only allow RPC connections from localhost

# General settings
server=1                 # Accept command line and JSON-RPC commands
daemon=1                 # Run in the background as a daemon
txindex=1                # Maintain a full transaction index (useful for blockchain exploration)

# You can add more configuration options here if needed
CONFEOF


echo "✓ Verus configuration created."

# ---------------------------------------------------------------------
# STEP 8.5: Download Verus Bootstrap (to avoid full chain sync)
# ---------------------------------------------------------------------
echo
echo "STEP 8.5: Downloading and installing Verus blockchain bootstrap..."

# Create directory for bootstrap download
echo "• Preparing for bootstrap download..."
BOOTSTRAP_DIR=$(mktemp -d)
cd "$BOOTSTRAP_DIR"

# Download the bootstrap file
echo "• Downloading Verus bootstrap..."
wget https://bootstrap.verus.io/VRSC-bootstrap.tar.gz

# Extract the bootstrap data
echo "• Extracting bootstrap data (this may take some time)..."
tar -xvzf VRSC-bootstrap.tar.gz

# Install the bootstrap data for root user
echo "• Installing bootstrap data for root user..."
mkdir -p /root/.komodo/VRSC/
cp -r blocks chainstate /root/.komodo/VRSC/

# If we have a new user, install for them too
if [[ -n "$NEW_USERNAME" ]]; then
    echo "• Installing bootstrap data for $NEW_USERNAME..."
    mkdir -p /home/$NEW_USERNAME/.komodo/VRSC/
    cp -r blocks chainstate /home/$NEW_USERNAME/.komodo/VRSC/
    chown -R $NEW_USERNAME:$NEW_USERNAME /home/$NEW_USERNAME/.komodo
fi

# Clean up the temporary directory
cd /
rm -rf "$BOOTSTRAP_DIR"

echo "✓ Verus bootstrap installed successfully."
echo "• Initial blockchain sync will be much faster now!"
echo "• Note: The 'rpcuser' and 'rpcpassword' are only for internal wallet communication."
echo "  You don't need to remember these values for normal wallet usage."
# ---------------------------------------------------------------------
# Clean up package cache to free disk space
echo "• Cleaning up package cache..."
apt autoremove -y
apt clean

# Display IP addresses for easy connection via RDP
echo "• Your current IP addresses (for RDP connection):"
ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}'

# ---------------------------------------------------------------------
# Installation Complete
# ---------------------------------------------------------------------
echo
echo "========================================================"
echo "   INSTALLATION COMPLETE"
echo "========================================================"
echo
echo "Verus wallet has been installed successfully."
echo
echo "TO FINISH SETUP:"
echo "1. The sudo user $NEW_USERNAME has been created for you."
echo
echo "2. Log in as $NEW_USERNAME and run "setup-2fa" to configure 2FA for RDP"
echo "   (You'll need to scan a QR code with Aegis Authenticator)"
echo
echo "TO USE THE SYSTEM:"
echo "1. Connect via RDP to this machine using the IP addresses shown above"
echo "2. Log in with your username, password, AND the 6-digit code from your authenticator app"
echo "3. Open a terminal and type "verus" to start the wallet"
echo "4. The first start will take time as it synchronizes the blockchain"
echo
echo "ABOUT RPC CONFIGURATION:"
echo "• The "rpcuser" and "rpcpassword" in the Verus configuration are"
echo "  only used for internal communication between wallet components"
echo "• You do NOT need to use these for logging in or using the wallet"
echo "• These settings are automatically configured for security"
echo
echo "IMPORTANT SECURITY RECOMMENDATIONS:"
echo "1. Create a dedicated non-root user for Verus operations"
echo "2. Back up your wallet data regularly"
echo "3. Consider hardware wallets for large amounts"
echo "4. Keep your system updated with 'apt update && apt upgrade'"
echo
echo "========================================================"

exit 0
