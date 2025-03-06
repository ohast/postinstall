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
- **Two-Factor Authentication**: Configures Google Authenticator for RDP (compatible with Aegis Authenticator)
- **Verus Wallet**: Downloads and installs the latest Verus wallet software
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

2. Configure Two-Factor Authentication:
   ```bash
   sudo setup-2fa
   ```
   - Scan the displayed QR code with Aegis or Google Authenticator
   - Save the emergency scratch codes in a secure location

3. Connect via RDP:
   - Use the IP address displayed at the end of the script
   - Login with your username, password, AND the 6-digit code from your authenticator app

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
