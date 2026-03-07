# ACME SSL Engine

A lightweight ACME certificate automation engine built with **ACME.sh**.

This project demonstrates how SSL/TLS certificates can be issued and managed automatically using the ACME protocol. It is designed to be simple, portable, and deployable on the [Railway](https://railway.app) platform with a single click.

> **Educational Purpose**
> This project is an educational project, a DevOps automation example, and a cybersecurity learning exercise. It is intended as a personal portfolio demonstration of ACME protocol automation concepts.

**Author:** Liviu Bucel

---

## Table of Contents

1. [What is the ACME Protocol?](#what-is-the-acme-protocol)
2. [How TLS Certificates Work](#how-tls-certificates-work)
3. [What is ACME.sh?](#what-is-acmesh)
4. [How This Project Works](#how-this-project-works)
5. [How to Run Locally](#how-to-run-locally)
6. [How to Deploy on Railway](#how-to-deploy-on-railway)
7. [Security Considerations](#security-considerations)

---

## What is the ACME Protocol?

**ACME** (Automatic Certificate Management Environment) is an open standard protocol defined in [RFC 8555](https://tools.ietf.org/html/rfc8555). It allows software agents to automatically obtain, renew, and revoke digital certificates from Certificate Authorities (CAs) without manual intervention.

ACME was originally developed by the **Let's Encrypt** team to enable free, automated, and open certificate issuance. Today it is supported by multiple CAs including ZeroSSL, Buypass, SSL.com, and others.

The ACME protocol works by having a client prove control over a domain using one of several challenge types:

- **HTTP-01** – place a token at a known URL on the domain
- **DNS-01** – create a DNS TXT record for the domain
- **TLS-ALPN-01** – serve a special certificate during TLS negotiation

---

## How TLS Certificates Work

TLS (Transport Layer Security) certificates are cryptographic documents that:

1. **Identify** a server to clients (authentication)
2. **Encrypt** the connection between client and server (confidentiality)
3. **Ensure data integrity** during transmission

The certificate lifecycle:

1. Generate a **private key** on the server
2. Create a **Certificate Signing Request (CSR)** containing the domain name and public key
3. Submit the CSR to a **Certificate Authority (CA)**
4. The CA validates **domain ownership** via an ACME challenge
5. The CA issues and signs the **certificate**
6. Install the certificate on the server
7. **Renew** the certificate before it expires (Let's Encrypt certificates expire after 90 days)

---

## What is ACME.sh?

[ACME.sh](https://github.com/acmesh-official/acme.sh) is a pure Unix shell script implementation of the ACME protocol client. Key features:

- Supports **Let's Encrypt**, **ZeroSSL**, **Buypass**, **SSL.com**, and more
- Supports **100+ DNS providers** for DNS-01 validation
- Supports **wildcard certificates** (`*.example.com`)
- Handles **automatic renewal** via cron or other schedulers
- Requires only standard Unix tools (curl, openssl)
- No dependencies on Python, Ruby, or other runtimes

Install with a single command:

```bash
curl https://get.acme.sh | sh
```

---

## How This Project Works

The repository contains the following scripts:

| File | Purpose |
|------|---------|
| `install.sh` | Installs required packages and ACME.sh |
| `start.sh` | Entry point — installs ACME.sh if needed, then keeps the service alive |
| `issue-cert.sh` | Demonstrates how to issue a certificate for a domain |
| `renew.sh` | Renews all managed certificates near expiration |
| `Dockerfile` | Container image definition for portable deployment |
| `railway.json` | Railway platform deployment configuration |

**Startup flow:**

1. Railway (or Docker) runs `bash start.sh`
2. `start.sh` checks whether ACME.sh is installed; if not, it runs `install.sh`
3. `install.sh` installs `curl`, `openssl`, and `socat` if missing, then installs ACME.sh
4. `start.sh` prints `ACME SSL Engine started successfully` and enters a keep-alive loop
5. Certificates can be issued on demand with `issue-cert.sh` and renewed with `renew.sh`

---

## How to Run Locally

### Option 1: Directly on Linux / macOS

```bash
# Clone the repository
git clone https://github.com/liviubucel/ssl-acme-engine.git
cd ssl-acme-engine

# Make scripts executable
chmod +x install.sh start.sh issue-cert.sh renew.sh

# Install ACME.sh
bash install.sh

# Start the engine
bash start.sh
```

### Option 2: Docker

```bash
# Build the image
docker build -t ssl-acme-engine .

# Run the container
docker run --rm ssl-acme-engine
```

### Issue a certificate (requires a real domain and DNS access)

```bash
# Set default CA
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt

# Issue certificate using DNS challenge
bash issue-cert.sh yourdomain.com
```

### Renew all certificates

```bash
bash renew.sh
```

---

## How to Deploy on Railway

1. Fork or push this repository to your GitHub account
2. Log in to [Railway](https://railway.app)
3. Click **New Project → Deploy from GitHub repo**
4. Select this repository
5. Railway will automatically detect `railway.json` and run `bash start.sh`
6. The service will start, install ACME.sh, and remain active

The logs should show:

```
ACME SSL Engine started successfully
```

---

## Security Considerations

### Protecting Private Keys

- Private keys generated by ACME.sh are stored in `~/.acme.sh/<domain>/`
- **Never commit private keys to version control**
- Restrict file permissions: `chmod 600 ~/.acme.sh/<domain>/<domain>.key`
- In production, use encrypted storage or a secrets manager (e.g., Vault, AWS Secrets Manager)

### Securing DNS API Credentials

- DNS challenge automation requires API tokens for your DNS provider
- Store credentials as **environment variables**, never hardcoded in scripts
- Use the minimum required permissions for the DNS API token (ideally write-only access to TXT records)
- Rotate DNS API credentials regularly

### Certificate Lifecycle Management

- Let's Encrypt certificates expire after **90 days**
- ACME.sh automatically renews certificates when they are within **30 days** of expiration
- Schedule `renew.sh` to run twice daily (e.g., via cron) to ensure timely renewal
- Monitor certificate expiration using tools like `openssl s_client` or a monitoring service

### Avoiding Exposure of Sensitive Data

- Do not log certificate contents or private key material
- Use HTTPS for all endpoints that serve certificate-protected traffic
- Review ACME.sh configuration files (`~/.acme.sh/account.conf`) to ensure no credentials are accidentally exposed

---

## Technologies

- [ACME.sh](https://github.com/acmesh-official/acme.sh) — ACME protocol client
- [OpenSSL](https://www.openssl.org/) — cryptographic operations
- [Railway](https://railway.app) — cloud deployment platform
- [Docker](https://www.docker.com/) — containerization
- [Let's Encrypt](https://letsencrypt.org/) — free, automated CA

---

## License

MIT License

