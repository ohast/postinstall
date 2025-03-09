# Post-Installation Scripts Collection

![GitHub last commit](https://img.shields.io/github/last-commit/ohast/postinstall)
![License](https://img.shields.io/github/license/ohast/postinstall?color=blue)

A collection of post-installation scripts for various Linux distributions. These scripts automate the setup process after a fresh OS installation, including software installation, security hardening, and environment configuration.

## Available Scripts

### Debian 12 Post-Installation with Verus Wallet Setup

This script automates the setup process after a fresh Debian 12 installation, with a focus on installing and configuring the Verus cryptocurrency wallet with security in mind.

#### Features:

- **System Update & Basic Tools**: Updates the system and installs essential tools and utilities
- **Desktop Environment**: Installs XFCE desktop environment for a lightweight experience
- **Remote Access**: Sets up XRDP for remote desktop connections
- **Two-Factor Authentication**: Optionally configures Google Authenticator for RDP during installation (compatible with Aegis Authenticator)
- **Verus Wallet**: 
    - Automatically fetches and installs the latest Verus wallet release from GitHub
    - Downloads the blockchain bootstrap to significantly reduce initial sync time
- **Security Hardening**: Sets up firewall rules and basic security measures
- **Automatic Configuration**: Creates proper configuration files for all components

#### Usage:

```bash
# Make the script executable
chmod +x debian12_post_install_verus_wallet.sh

# Run the script as root
sudo ./debian12_post_install_verus_wallet.sh
```

#### After Installation:

1. Create a regular user (if needed):
   ```bash
   sudo adduser yourusername
   ```

2. Configure Two-Factor Authentication (if not done during installation):
   ```bash
   sudo setup-2fa
   ```
   - Scan the displayed QR code with Aegis or Google Authenticator
   - Save the emergency scratch codes in a secure location

3. Connect via RDP:
   - Use the IP address displayed at the end of the script
   - Login with your username, password, AND the 6-digit code from your authenticator app

4. Using Verus Wallet:
   - The wallet will start with a pre-synced blockchain (thanks to the bootstrap)
   - You can start using the wallet immediately with minimal wait time
   - The script installs the latest available version, always keeping you up-to-date

## Detailed Guide: Two-Factor Authentication (2FA) Setup

The Debian 12 post-installation script includes robust Two-Factor Authentication for securing remote desktop (RDP) connections. This significantly enhances security by requiring something you know (password) and something you have (authenticator app).

### 2FA Overview:

- **Implementation**: Uses Google Authenticator PAM module (compatible with any TOTP app)
- **Recommended App**: Aegis Authenticator (open-source, supports backups)
- **Security Benefits**: Protects against password-based attacks, adds second layer of verification
- **Setup Options**: Can be configured during installation or after setup

### Setting Up 2FA During Installation:

1. When running the installation script, you'll be prompted:
   ```
   Do you want to set up 2FA for user [username] now? (y/n)
   ```

2. If you select "y":
   - The script will generate a QR code on screen
   - You'll need to scan this QR code with your authenticator app (Aegis or Google Authenticator)
   - Emergency scratch codes will be displayed - SAVE THESE in a secure location
   - 2FA will be immediately active for RDP connections

3. Configuration details:
   - Time-based tokens (TOTP) with 30-second validity
   - 3 login attempts before timeout
   - 3 concurrent valid codes (helps with time drift)
   - Rate limiting enabled for security

### Setting Up 2FA After Installation:

If you chose not to set up 2FA during installation or need to set it up for additional users:

1. Log into the system (locally or via RDP without 2FA if not yet enabled)

2. Run the setup command:
   ```bash
   sudo setup-2fa
   ```
   
3. Follow the on-screen instructions:
   - Press Enter to initiate the setup
   - A QR code will be displayed on the terminal
   - Scan the QR code with your authenticator app
   - Save the emergency scratch codes securely
   - 2FA will be activated immediately

### Connecting with 2FA Enabled:

1. Open your RDP client and connect to your server's IP address

2. When prompted for login:
   - Enter your username
   - In the password field, enter: your password followed by the current 6-digit code from your authenticator app
   
3. Troubleshooting tips:
   - Ensure your device's time is correctly synchronized
   - If login fails, wait for a new code to generate in your app
   - In emergency situations, you can use one of your scratch codes instead of the 6-digit code

### Security Recommendations:

- **Backup Recovery Codes**: Store the emergency scratch codes securely, separate from your authenticator device
- **App Backup**: Use Aegis Authenticator's encrypted backup feature to prevent lockout if you lose your device
- **Multiple Administrators**: Consider setting up 2FA for multiple admin users in case one loses access
- **SSH Access**: Consider maintaining SSH access as a backup method with key-based authentication

## Repository Structure

```
postinstall/
├── debian12_post_install_verus_wallet.sh  # Debian 12 script with Verus wallet
├── [future distributions and configurations]
└── README.md
```

## Planned Scripts

- Ubuntu Server post-installation
- Arch Linux base setup
- Fedora Workstation configuration
- Raspberry Pi OS optimization

## Contributing

Contributions are welcome! If you'd like to add a script for another distribution or improve an existing one:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-script`)
3. Add your script with detailed comments explaining each section
4. Commit your changes (`git commit -am 'Add script for Distribution X'`)
5. Push to the branch (`git push origin feature/your-script`)
6. Create a new Pull Request

## Security Considerations

- These scripts should be reviewed carefully before execution
- Some scripts require root permissions - make sure you understand what they do
- Always back up important data before running post-installation scripts
- Consider additional security measures for production environments

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Disclaimer

These scripts are provided "as is", without warranty of any kind. Use at your own risk.
