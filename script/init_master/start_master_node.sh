#!/bin/bash

###############################################
# 启动 kubeadm
###############################################
kubeadm init --config=/etc/kubernetes/kubeadm-config.yaml

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

sleep 1m

###############################################
# 检查集群状态
###############################################
kubectl get pod -n kube-system
kubectl get nodes


