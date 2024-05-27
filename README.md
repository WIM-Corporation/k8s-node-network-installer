# k8s-node-network-installer

https://github.com/WIM-Corporation/k8s-node-network-installer.git

Initializes a k8s node network configuration.

## Install openssh server

```bash
./configure-ssh.sh
```

## Set netplan

```bash
./configure_netplan.sh 192.168.1.<d-record-1> 192.168.5.<d-record-2>
```

## Update hostname

```bash
./update-hostname.sh <new_hostname>
```

If the hostname is successfully changed, the login session will be terminated.
