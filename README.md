# k8s-node-network-installer

https://github.com/WIM-Corporation/k8s-node-network-installer.git

초기화 과정은 다음과 같습니다.

## openssh server 설치

```bash
./configure-ssh.sh
```

## netplan 설정

```bash
./configure_netplan.sh 192.168.1.<d-record-1> 192.168.5.<d-record-2>
```
