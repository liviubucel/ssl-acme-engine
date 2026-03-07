FROM node:20-alpine

RUN apk add --no-cache \
    bash \
    curl \
    socat \
    openssl

WORKDIR /app

COPY . .

RUN chmod +x /app/install.sh /app/start.sh /app/issue-cert.sh /app/renew.sh

RUN npm install

EXPOSE 8080

CMD ["node", "-e", "console.log('Node is running'); setInterval(()=>{},1000)"]
