FROM python:3.11-slim

ENV BACKEND_PORT=${BACKEND_PORT}
ENV AWS_REGION=${AWS_REGION}
ENV COGNITO_POOL_ID=${COGNITO_POOL_ID}
ENV COGNITO_CLIENT_ID=${COGNITO_CLIENT_ID}
ENV DATABASE_URL=${DATABASE_URL}
ENV DATABASE_USERNAME=${DATABASE_USERNAME}
ENV DATABASE_PASSWORD=${DATABASE_PASSWORD}
ENV AWS_CREDENTIALS=${AWS_CREDENTIALS}

WORKDIR /usr/src/app
COPY requirements.txt ./

RUN mkdir -p /root/.aws

RUN echo "#!/bin/sh" > start.sh && \
    echo "echo \$AWS_CREDENTIALS > /root/.aws/credentials" >> start.sh && \
    chmod +x start.sh

RUN pip install -r requirements.txt
COPY app.py ./
COPY db_handler.py ./
EXPOSE ${BACKEND_PORT}
CMD ["/bin/sh", "-c", "./start.sh && python app.py"]