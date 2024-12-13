FROM node:21-slim
ENV FRONTEND_PORT=${FRONTEND_PORT}
ENV BACKEND_SERVICE_NAME=${BACKEND_SERVICE_NAME}
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY public ./public
COPY src ./src
EXPOSE ${FRONTEND_PORT}
CMD [ "npm", "start" ]