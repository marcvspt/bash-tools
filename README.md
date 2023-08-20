# Bash tools

## Install
```bash
mkdir ~/.local/bin
git clone --depth 1 https://github.com/marcvspt/bash-tools.git
cd bash-tools/
cp *.sh ~/.local/bin/

echo 'export PATH=$PATH:~/.local/bin/' >> ~/.bashrc # ~/.zshrc
source ~/.bashrc # ~/.zshrc
```

## Tools
### Docker purge
This tool delete all resources of docker:
```bash
[o] Usage: ./docker-purge.sh

	-c  Delete containers.

	-i  Delete images.

	-v  Delete volumes.

	-n  Delete networks.

	-a  Delete all (containers, images, volumes, networks).

	-h  Show this help message.

```

## Network host scanner
```bash
[o] Usage: ./network-scan.sh

	-n <ip-network/prefix-mask> The network with prefix to scan.

	-h                          Show this help pannel.

[o] Examples:

	[%] ./network-scan.sh -n 10.0.0.0/11

	[%] ./network-scan.sh -n 172.16.32.0/16

	[%] ./network-scan.sh -n 192.168.1.0/29
```

## Host port scanner
```bash
[o] Usage: ./port-scan.sh

	-d <ip-address or domain>   The IP, name or domain to scan.

	-p <port(s)>                The ports that want to scan.

	-h                          Show this help pannel.

[o] Examples:

	[%] ./port-scan.sh -d 192.168.1.150 -p 80

	[%] ./port-scan.sh -d 192.168.1.150 -p 1-1000

	[%] ./port-scan.sh -d 192.168.1.150 -p 22,80,3306

	[%] ./port-scan.sh -d 192.168.1.150 -p 1-1000,3306
```

## Process monitoring diferences
```bash
[o] Usage: ./proc-mon.sh
```