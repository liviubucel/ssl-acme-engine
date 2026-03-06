FROM ubuntu:22.04

RUN apt update && apt install -y \
curl \
socat \
openssl \
cron \
git

RUN git clone https://github.com/acmesh-official/acme.sh /root/acme.sh

RUN /root/acme.sh/acme.sh --install

ENV PATH="/root/.acme.sh:${PATH}"

WORKDIR /app

COPY start.sh /app/start.sh

RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]
