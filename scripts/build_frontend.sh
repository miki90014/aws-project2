#!/usr/bin/bash
set +x

source .bashrc
git clone https://github.com/$GITHUB_OWNER/$GITHUB_REPO $WORKSPACE
sed -i "s/ENV FRONTEND_PORT=.*/ENV FRONTEND_PORT=$FRONTEND_PORT/" $WORKSPACE/frontend/Dockerfile
sed -i "s/ENV BACKEND_SERVICE_NAME=.*/ENV BACKEND_SERVICE_NAME=$BACKEND_SERVICE_NAME/" $WORKSPACE/frontend/Dockerfile
sed -i 's|"proxy": "http://backend:5000"|"proxy": "'"http://${BACKEND_SERVICE}:5000"'"|' $WORKSPACE/frontend/package.json

cd $WORKSPACE/frontend
sudo docker build -t frontend-container .
sudo docker run --name frontend-container -p ${EXPOSED_FRONTEND_PORT}:${FRONTEND_PORT} frontend-container