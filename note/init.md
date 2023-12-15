# 初始化实验环境

基于debian-10.12搭建 【1 master + 2 worker】的k8s集群

## Step1 安装基础系统，进行基础配置

安装完成后基本操作：
```shell
apt update && apt upgrade
apt install -y ssh vim git

# 允许root远程登录
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
service ssh restart

# 查看ip
ip addr

# clone脚本仓库
git clone https://github.com/wtudio/k8s.git

```

## Step2-1 初始化master节点

在要配置为master节点的机器上：

0. 首先进入指定目录：`cd script/init_master`
1. 固定master节点ip，可通过路由器绑定mac与ip
2. 初始化环境：`./init_master_node.sh YOUR_MASTER_NODE_NAME`
3. 启动k8s并记录join指令：`./start_master_node.sh`
4. 安装flannel：`./install_flannel.sh`
5. 安装dashboard：`./install_dashboard.sh`
6. 创建管理员账号：`./create_admin_role.sh`


## Step3 初始化worker节点

在要配置为worker节点的机器上：

0. 首先进入指定目录：`cd script/init_worker`
1. 初始化环境：`./init_worker_node.sh YOUR_WORK_NODE_NAME`
2. 加入master（在master启动k8s之后）：
```shell
kubeadm join 192.168.0.105:6443 --token xxxx \
        --discovery-token-ca-cert-hash sha256:xxxx
```

