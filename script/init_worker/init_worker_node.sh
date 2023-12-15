#!/bin/bash

###############################################
# 配置，需根据实际节点设置
###############################################
if [ $# != 2 ] ; then
echo "USAGE: $0 node_hostname local_node_ip"
echo " e.g.: $0 kube-master-1 192.168.0.107"
exit 1;
fi

node_hostname=$1
local_node_ip=$2

###############################################
# 修改host
###############################################
hostnamectl set-hostname ${node_hostname}
sed -i "s/debian1012/${node_hostname}/g" /etc/hosts
echo -e "127.0.0.1\t${node_hostname}" >> /etc/hosts
echo -e "${local_node_ip}\t${node_hostname}" >> /etc/hosts

###############################################
# 安装基础软件
###############################################
apt-get update && apt-get upgrade
apt-get install -y curl apt-transport-https ca-certificates gnupg lsb-release

###############################################
# 安装containerd.io
###############################################
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt-get install -y containerd.io

containerd config default > /etc/containerd/config.toml

sed -i 's#sandbox_image = "k8s.gcr.io/pause:3.6"#sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.6"#g' /etc/containerd/config.toml

sed -i '/\[plugins."io.containerd.grpc.v1.cri".registry.mirrors]/a\        \[plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]' /etc/containerd/config.toml
sed -i '/\[plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]/a\          endpoint = \["registry.aliyuncs.com\/google_containers"]' /etc/containerd/config.toml

systemctl restart containerd

###############################################
# 关闭防火墙
###############################################
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

###############################################
# 关闭selinux
###############################################
sed -i "s#=enforcing#=disabled#g" /etc/selinux/config

###############################################
# 关闭swap
###############################################
swapoff -a && sysctl -w vm.swappiness=0
sed -ri '/^[^#]*swap/s@^@#@' /etc/fstab

###############################################
# K8S相关配置
###############################################
cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

modprobe br_netfilter
sysctl -p /etc/sysctl.d/k8s.conf

echo -e "echo 1 > /proc/sys/net/ipv4/ip_forward" >> $HOME/.bashrc

###############################################
# 安装kubelet、kubectl、kubeadm
###############################################
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet=1.24.0-00 kubeadm=1.24.0-00
