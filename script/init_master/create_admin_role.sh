#!/bin/bash

###############################################
# 创建管理员用户
###############################################

cat <<EOF > ./admin-role.yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: admin-cluster-role-binding
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: admin-service-account
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-service-account
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
---
apiVersion: v1
kind: Secret
metadata:
  name: admin-secret
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: admin-service-account
type: kubernetes.io/service-account-token
EOF

kubectl create -f admin-role.yaml
