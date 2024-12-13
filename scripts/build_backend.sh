#!/usr/bin/bash
set +x

source .bashrc
git clone https://github.com/$GITHUB_OWNER/$GITHUB_REPO $WORKSPACE
sed -i "s/ENV BACKEND_PORT=.*/ENV BACKEND_PORT=$BACKEND_PORT/" $WORKSPACE/backend/Dockerfile
sed -i "s/ENV AWS_REGION=.*/ENV AWS_REGION=$AWS_REGION/" $WORKSPACE/backend/Dockerfile
sed -i "s/ENV COGNITO_POOL_ID=.*/ENV COGNITO_POOL_ID=$COGNITO_POOL_ID/" $WORKSPACE/backend/Dockerfile
sed -i "s/ENV COGNITO_CLIENT_ID=.*/ENV COGNITO_CLIENT_ID=$COGNITO_CLIENT_ID/" $WORKSPACE/backend/Dockerfile
sed -i "s/ENV DATABASE_URL=.*/ENV DATABASE_URL=$DATABASE_URL/" $WORKSPACE/backend/Dockerfile
sed -i "s/ENV DATABASE_USERNAME=.*/ENV DATABASE_USERNAME=$DATABASE_USERNAME/" $WORKSPACE/backend/Dockerfile
sed -i "s/ENV DATABASE_PASSWORD=.*/ENV DATABASE_PASSWORD=$DATABASE_PASSWORD/" $WORKSPACE/backend/Dockerfile
sed -i "s/ENV DATABASE_PASSWORD=.*/ENV DATABASE_PASSWORD=$DATABASE_PASSWORD/" $WORKSPACE/backend/Dockerfile
cd $WORKSPACE
cp /home/ubuntu/.aws/credentials $WORKSPACE/backend
cd $WORKSPACE/backend
sudo docker build -t backend-container .
sudo docker run --name backend-container -p ${BACKEND_PORT}:${BACKEND_PORT} backend-container