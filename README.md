# ACME SSL Engine

A lightweight experimental project demonstrating how to automate the issuance and management of TLS/SSL certificates using the **ACME protocol**.

This repository explores how certificate automation works internally and how a minimal certificate engine can be built using **ACME.sh**, one of the most widely used ACME clients.

The project is intended as a **learning and portfolio exercise**, focusing on certificate lifecycle automation, security infrastructure, and DevOps workflows.

---

## Overview

TLS certificates are essential for securing modern web services. The **ACME protocol** allows servers and applications to automatically request, validate, and renew certificates from trusted Certificate Authorities.

This project demonstrates how an ACME client can be used to:

* generate private keys
* request certificates from public Certificate Authorities
* validate domain ownership
* renew certificates automatically

The repository provides a minimal environment that can be used as a starting point for building certificate automation tools or learning how ACME infrastructure works.

---

## Technologies

This project primarily uses:

* **ACME.sh** – an ACME client written in shell script
* **OpenSSL** – for cryptographic operations
* **Linux / Unix environments**
* **DNS-based validation (ACME DNS challenge)**

---

## Supported Certificate Authorities

ACME.sh supports multiple Certificate Authorities, including:

* Let's Encrypt
* ZeroSSL
* SSL.com
* Buypass

Because ACME.sh is CA-agnostic, the same client can be used to request certificates from different providers.

---

## Features

* Automated SSL/TLS certificate issuance
* Support for DNS validation challenges
* Wildcard certificate support
* Automatic certificate renewal
* Lightweight and portable setup
* Works in containerized environments or standard Linux systems

---

## Installation

Install ACME.sh using the official installation script:

```id="axm8u0"
curl https://get.acme.sh | sh
```

After installation, verify the version:

```id="1z1z6d"
acme.sh --version
```

---

## Example Usage

Set the default Certificate Authority:

```id="9iho78"
acme.sh --set-default-ca --server letsencrypt
```

Issue a certificate using a DNS challenge:

```id="7n9i1k"
acme.sh --issue --dns -d example.com
```

Issue a wildcard certificate:

```id="ty9xj6"
acme.sh --issue --dns -d example.com -d *.example.com
```

Certificates are typically stored in:

```id="n0p4x2"
~/.acme.sh/domain.com/
```

---

## Certificate Lifecycle

A typical ACME certificate workflow includes:

1. Generating a private key
2. Creating a Certificate Signing Request (CSR)
3. Proving domain ownership via challenge validation
4. Issuing the certificate
5. Renewing the certificate before expiration

This project focuses on understanding and automating that lifecycle.

---

## Security Considerations

When working with certificates and private keys, it is important to:

* protect private keys from unauthorized access
* securely store DNS credentials when using DNS challenges
* use secure environments for certificate automation
* implement monitoring for certificate expiration

---

## Educational Purpose

This project was created as part of a personal learning journey exploring:

* TLS and PKI systems
* certificate automation
* DevOps security workflows
* infrastructure security

It is intended as a small portfolio project demonstrating practical experimentation with certificate management technologies.

---

## Author

Liviu Bucel

Interested in:

* cybersecurity
* secure infrastructure
* cloud technologies
* DevOps automation
* web security

---

## License

MIT License
