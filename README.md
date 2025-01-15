# k8s-node-network-installer

쿠버네티스 노드의 네트워크 설정을 초기화 하는 스크립트

- ~vSphere 의 템플릿으로 VM 생성~
- `네트워크 설정 초기화`
- ~Ansible 로 쿠버네티스 클러스터 join~

> network interface: ens192
> vlan: 5
>
> 위 설정에 맞춰서 작성되었으며, 환경에 맞게 수정해서 사용

## run

```sh
./setup.sh <HOST_NAME>
```
