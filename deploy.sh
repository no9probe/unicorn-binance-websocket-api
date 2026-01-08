#!/bin/bash

# 配置
SERVER="ubuntu@54.250.22.54"
SSH_KEY="~/.ssh/aws1.pem"
REMOTE_DIR="/home/ubuntu/unicorn-binance-websocket-api"
REMOTE_PIP="/home/ubuntu/miniconda3/envs/qixian/bin/pip"
PACKAGE_NAME="unicorn_binance_websocket_api"

# 本地目录
LOCAL_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== 1. 同步源码到服务器 ==="
rsync -avz --exclude='.git' --exclude='__pycache__' --exclude='*.pyc' --exclude='*.so' --exclude='*.egg-info' --exclude='dist' --exclude='build' \
    -e "ssh -i $SSH_KEY" \
    "$LOCAL_DIR/" "$SERVER:$REMOTE_DIR/"

echo "=== 2. 在服务器上安装编译依赖并安装包 ==="
ssh -i $SSH_KEY $SERVER << EOF
    echo "检查并安装 gcc..."
    if ! command -v gcc &> /dev/null; then
        echo "安装 gcc..."
        sudo apt-get update && sudo apt-get install -y gcc python3-dev
    fi

    echo "卸载旧版本..."
    $REMOTE_PIP uninstall -y $PACKAGE_NAME 2>/dev/null || true

    echo "安装新版本（从源码编译）..."
    cd $REMOTE_DIR
    $REMOTE_PIP install .

    echo "验证安装..."
    $REMOTE_PIP show $PACKAGE_NAME | grep -E "^(Name|Version):"
EOF

echo "=== 完成 ==="
