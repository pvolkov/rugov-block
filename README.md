# RUGOV IP Blocker

This repository contains scripts for automatically updating `iptables` rules to block IP addresses listed in a blacklist. The blacklist is periodically fetched from a specified URL and used to update the firewall rules on a server. This setup ensures that your server remains protected from unwanted traffic as defined by the blacklist.

## Files in this repository

1. **install.sh**: A script to set up the environment and configure automatic updates.
2. **updater.sh**: A script to fetch the latest blacklist and update `iptables` rules.

## Prerequisites

Ensure that the following packages are installed on your system:
- `iptables`
- `iptables-persistent`
- `wget`

You can install these packages using the following commands:

### Ubuntu 22.04 and Debian 12

```bash
sudo apt-get update
sudo apt-get install iptables iptables-persistent wget
```
## Installation
1. **Clone the repository:**
```bash
git clone https://github.com/pvolkov/rugov-block.git
cd rugov-block
```
2. **Run the installation script:**
```
sudo ./install.sh
```

This script will:

* Create the necessary working directory (`/var/log/rugov_block`)
* Copy `updater.sh` and `cleaner.sh` to the working directory
* Make the scripts executable
* Run `updater.sh` for the first time to initialize the rules
* Create a symbolic link in `/etc/cron.daily/` to ensure `updater.sh` runs daily

## Usage
### Updater Script

The `updater.sh` script performs the following actions:

* Creates a custom `iptables` chain named `RUGOV` (if it doesn't already exist)
* Fetches the latest blacklist from the specified URL
* Adds rules to the `RUGOV` chain to block IP addresses listed in the blacklist
* Saves the updated `iptables` rules

### Cleaner Script

The `cleaner.sh` script performs the following actions:

* Flushes all rules in the `RUGOV` chain
* Deletes the `RUGOV` chain from `iptables`
* Logs the actions to `/var/log/rugov_block/update_log.txt`

To manually run the cleaner script:
```
sudo /var/log/rugov_block/cleaner.sh

```

### Customization

You can customize the URL of the blacklist or the working directory by editing the corresponding variables in the scripts:

* `BLACKLIST_URL` in `updater.sh`
* `WORK_DIR` in all scripts

### Logging

All actions performed by the `updater.sh` script are logged to `/var/log/rugov_block/update_log.txt`.

### Testing

These scripts have been tested on:

* **Ubuntu 22.04**
* **Debian 12**

## Inspired by
[iptables-rugov-block](https://github.com/freemedia-tech/iptables-rugov-block)
