# StormMasterMux

Run both StormDNS and MasterDnsVPN on the same server and the same public DNS port (`53`) using a lightweight DNS multiplexer.

---

# Languages

* [English](#english)
* [فارسی](#فارسی)

---

# English

# Table of Contents

* [What is StormMasterMux?](#what-is-stormmastermux)
* [How It Works](#how-it-works)
* [Features](#features)
* [Architecture](#architecture)
* [Requirements](#requirements)
* [Quick Start](#quick-start)
* [Cloudflare DNS Configuration](#cloudflare-dns-configuration)
* [NS Domain Configuration](#ns-domain-configuration)
* [Installation](#installation)
* [Service Management](#service-management)
* [Logs](#logs)
* [Project Structure](#project-structure)
* [Default Ports](#default-ports)
* [Security Notes](#security-notes)
* [Troubleshooting](#troubleshooting)
* [Credits](#credits)
* [License](#license)

---

# What is StormMasterMux?

StormMasterMux is a lightweight DNS multiplexer written in Go.

It allows you to run:

* StormDNS
* MasterDnsVPN

simultaneously on the same public DNS port (`53`) and the same server.

The multiplexer automatically routes DNS packets based on the requested domain.

Example:

```text
a.example.com  ---> StormDNS
b.example.com  ---> MasterDnsVPN
```

---

# How It Works

StormMasterMux listens on:

```text
UDP/TCP :53
```

When a DNS request arrives:

* if the request contains the StormDNS domain:

  * the packet is forwarded to StormDNS backend

* if the request contains the MasterDnsVPN domain:

  * the packet is forwarded to MasterDnsVPN backend

Backends listen only on localhost:

```text
127.0.0.1:5301
127.0.0.1:5302
```

This means:

* only one public port is exposed
* backend services remain private
* easier firewall management
* both projects work simultaneously

---

# Features

* Run StormDNS and MasterDnsVPN together
* Single public DNS port (`53`)
* Automatic domain-based routing
* Lightweight UDP/TCP DNS multiplexer
* Automatic installation
* Automatic key generation
* Automatic service creation
* Ubuntu 22/24 support
* IPv4 compatible

---

# Architecture

```text
Client
   |
   v
StormMasterMux (:53)
   |
   +---- a.example.com ---> StormDNS (127.0.0.1:5301)
   |
   +---- b.example.com ---> MasterDnsVPN (127.0.0.1:5302)
```

---

# Requirements

* Ubuntu 22.04 or 24.04
* Root access
* Public IPv4
* Domain managed in Cloudflare
* Open UDP/TCP port `53`

---

# Quick Start

## 1. Connect to server

```bash
ssh root@YOUR_SERVER_IP
```

---

## 2. Run installer

```bash
bash <(curl -Ls https://raw.githubusercontent.com/UnseenCore/stormmastermux/main/install.sh)
```

---

## 3. Enter configuration

Example:

```text
Public Server IP: 1.2.3.4

StormDNS Domain: a.example.com

MasterDnsVPN Domain: b.example.com
```

---

## 4. Done

Installer automatically:

* installs dependencies
* downloads StormDNS
* downloads MasterDnsVPN
* builds StormMasterMux
* configures services
* generates encryption keys
* starts all services

---

# Cloudflare DNS Configuration

Create these DNS records in Cloudflare.

| Type | Name | Content            |
| ---- | ---- | --------------  |
| NS    | a    | ns1.example.com  |
| NS    | b    | ns1.example.com  |

---

# Important

Cloudflare proxy MUST be disabled.

Correct:

```text
DNS Only
```

Wrong:

```text
Proxied
```

---

# NS Domain Configuration

You should create NS records for your domains.

Example:

| Type | Name | Content         |
| ---- | ---- | --------------- |
| NS   | a    | ns1.example.com |
| NS   | b    | ns1.example.com |

And create:

| Type | Name | Content        |
| ---- | ---- | -------------- |
| A    | ns1  | YOUR_SERVER_IP |

Example:

```text
ns1.example.com -> YOUR_SERVER_IP
```

---

# Installation

## Clone repository

```bash
git clone https://github.com/UnseenCore/stormmastermux.git

cd stormmastermux
```

---

## Run installer

```bash
chmod +x install.sh

./install.sh
```

---

# Service Management

## Check services

```bash
systemctl status stormdns

systemctl status masterdnsvpn

systemctl status stormmastermux
```

---

## Restart services

```bash
systemctl restart stormdns

systemctl restart masterdnsvpn

systemctl restart stormmastermux
```

---

# Logs

```bash
journalctl -u stormdns -f

journalctl -u masterdnsvpn -f

journalctl -u stormmastermux -f
```

---

# Project Structure

```text
stormmastermux/
├── cmd/
├── internal/
├── configs/
├── install.sh
├── go.mod
└── README.md
```

---

# Default Ports

| Service        | Port |
| -------------- | ---- |
| StormMasterMux | 53   |
| StormDNS       | 5301 |
| MasterDnsVPN   | 5302 |

---

# Security Notes

* Only port `53` should be public
* Backends should listen on localhost
* Keep firewall enabled
* Protect SSH access
* Use strong encryption keys

---

# Troubleshooting

## Port 53 busy

```bash
ss -lntup | grep :53
```

---

## Restart all services

```bash
systemctl restart stormdns
systemctl restart masterdnsvpn
systemctl restart stormmastermux
```

---

## View logs

```bash
journalctl -u stormmastermux -f
```

---

# Credits

This project uses and integrates the following projects:

## StormDNS

StormDNS is a DNS tunneling project designed for high-performance DNS-based communication.

Repository:

https://github.com/nullroute1970/StormDNS

All StormDNS related functionality belongs to its original authors.

---

## MasterDnsVPN

MasterDnsVPN is a DNS tunneling VPN project supporting encrypted DNS-based transport.

Repository:

https://github.com/masterking32/MasterDnsVPN

All MasterDnsVPN related functionality belongs to its original authors.

---

# License

MIT

---

---

# فارسی

# فهرست مطالب

* [StormMasterMux چیست؟](#stormmastermux-چیست)
* [نحوه کار](#نحوه-کار)
* [قابلیت‌ها](#قابلیتها)
* [معماری](#معماری)
* [پیش‌نیازها](#پیشنیازها)
* [شروع سریع](#شروع-سریع)
* [تنظیم DNS در Cloudflare](#تنظیم-dns-در-cloudflare)
* [تنظیم NS Domain](#تنظیم-ns-domain)
* [نصب](#نصب)
* [مدیریت سرویس‌ها](#مدیریت-سرویسها)
* [لاگ‌ها](#لاگها)
* [ساختار پروژه](#ساختار-پروژه)
* [پورت‌های پیش‌فرض](#پورتهای-پیشفرض)
* [نکات امنیتی](#نکات-امنیتی)
* [عیب‌یابی](#عیبیابی)
* [اعتبارات](#اعتبارات)
* [لایسنس](#لایسنس)

---

# StormMasterMux چیست؟

StormMasterMux یک DNS multiplexer سبک نوشته‌شده با Go است.

این پروژه اجازه می‌دهد:

* StormDNS
* MasterDnsVPN

به صورت همزمان روی:

* یک سرور
* و یک پورت عمومی DNS (`53`)

اجرا شوند.

Mux به صورت خودکار بسته‌های DNS را بر اساس دامنه route می‌کند.

مثال:

```text
a.example.com  ---> StormDNS
b.example.com  ---> MasterDnsVPN
```

---

# نحوه کار

StormMasterMux روی:

```text
UDP/TCP :53
```

گوش می‌دهد.

زمانی که درخواست DNS دریافت شود:

* اگر دامنه مربوط به StormDNS باشد:

  * بسته به backend استورم ارسال می‌شود

* اگر دامنه مربوط به MasterDnsVPN باشد:

  * بسته به backend مستر ارسال می‌شود

backend ها فقط روی localhost گوش می‌دهند:

```text
127.0.0.1:5301
127.0.0.1:5302
```

این باعث می‌شود:

* فقط یک پورت عمومی باز باشد
* backend ها private بمانند
* مدیریت firewall ساده‌تر شود
* هر دو پروژه همزمان اجرا شوند

---

# قابلیت‌ها

* اجرای همزمان StormDNS و MasterDnsVPN
* استفاده از یک پورت عمومی (`53`)
* route خودکار بر اساس دامنه
* multiplexer سبک UDP/TCP
* نصب خودکار
* تولید خودکار کلیدها
* ساخت خودکار سرویس‌ها
* پشتیبانی Ubuntu 22/24
* سازگار با IPv4

---

# معماری

```text
Client
   |
   v
StormMasterMux (:53)
   |
   +---- a.example.com ---> StormDNS (127.0.0.1:5301)
   |
   +---- b.example.com ---> MasterDnsVPN (127.0.0.1:5302)
```

---

# پیش‌نیازها

* Ubuntu 22.04 یا 24.04
* دسترسی root
* آی‌پی عمومی IPv4
* دامنه مدیریت‌شده در Cloudflare
* باز بودن پورت UDP/TCP `53`

---

# شروع سریع

## 1. اتصال به سرور

```bash
ssh root@YOUR_SERVER_IP
```

---

## 2. اجرای نصب‌کننده

```bash
bash <(curl -Ls https://raw.githubusercontent.com/UnseenCore/stormmastermux/main/install.sh)
```

---

## 3. وارد کردن اطلاعات

نمونه:

```text
Public Server IP: 1.2.3.4

StormDNS Domain: a.example.com

MasterDnsVPN Domain: b.example.com
```

---

## 4. پایان نصب

اسکریپت:

* وابستگی‌ها را نصب می‌کند
* StormDNS را دانلود می‌کند
* MasterDnsVPN را دانلود می‌کند
* StormMasterMux را build می‌کند
* سرویس‌ها را تنظیم می‌کند
* کلیدها را تولید می‌کند
* همه سرویس‌ها را اجرا می‌کند

---

# تنظیم DNS در Cloudflare

رکوردهای زیر را در Cloudflare ایجاد کنید.

| Type | Name | Content          |
| ---- | ---- | --------------   |
| NS   | a    | ns1.example.com  |
| NS   | b    | ns1.example.com  |

---

# مهم

Proxy کلودفلر باید غیرفعال باشد.

درست:

```text
DNS Only
```

غلط:

```text
Proxied
```

---

# تنظیم NS Domain

باید رکورد NS نیز ایجاد کنید.

مثال:

| Type | Name | Content         |
| ---- | ---- | --------------- |
| NS   | a    | ns1.example.com |
| NS   | b    | ns1.example.com |

و همچنین:

| Type | Name | Content        |
| ---- | ---- | -------------- |
| A    | ns1  | YOUR_SERVER_IP |

مثال:

```text
ns1.example.com -> YOUR_SERVER_IP
```

---

# نصب

## کلون کردن پروژه

```bash
git clone https://github.com/UnseenCore/stormmastermux.git

cd stormmastermux
```

---

## اجرای نصب‌کننده

```bash
chmod +x install.sh

./install.sh
```

---

# مدیریت سرویس‌ها

## بررسی سرویس‌ها

```bash
systemctl status stormdns

systemctl status masterdnsvpn

systemctl status stormmastermux
```

---

## ریستارت سرویس‌ها

```bash
systemctl restart stormdns

systemctl restart masterdnsvpn

systemctl restart stormmastermux
```

---

# لاگ‌ها

```bash
journalctl -u stormdns -f

journalctl -u masterdnsvpn -f

journalctl -u stormmastermux -f
```

---

# ساختار پروژه

```text
stormmastermux/
├── cmd/
├── internal/
├── configs/
├── install.sh
├── go.mod
└── README.md
```

---

# پورت‌های پیش‌فرض

| سرویس          | پورت |
| -------------- | ---- |
| StormMasterMux | 53   |
| StormDNS       | 5301 |
| MasterDnsVPN   | 5302 |

---

# نکات امنیتی

* فقط پورت `53` عمومی باشد
* backend ها روی localhost گوش دهند
* firewall فعال باشد
* دسترسی SSH را ایمن نگه دارید
* از کلیدهای قوی استفاده کنید

---

# عیب‌یابی

## اشغال بودن پورت 53

```bash
ss -lntup | grep :53
```

---

## ریستارت همه سرویس‌ها

```bash
systemctl restart stormdns
systemctl restart masterdnsvpn
systemctl restart stormmastermux
```

---

## مشاهده لاگ‌ها

```bash
journalctl -u stormmastermux -f
```

---

# اعتبارات

این پروژه از پروژه‌های زیر استفاده می‌کند:

## StormDNS

StormDNS یک پروژه DNS tunneling برای ارتباطات مبتنی بر DNS با کارایی بالا است.

ریپازیتوری:

https://github.com/nullroute1970/StormDNS

تمام قابلیت‌های مرتبط با StormDNS متعلق به توسعه‌دهندگان اصلی آن است.

---

## MasterDnsVPN

MasterDnsVPN یک پروژه VPN مبتنی بر DNS tunneling با پشتیبانی از ارتباط رمزنگاری‌شده است.

ریپازیتوری:

https://github.com/masterking32/MasterDnsVPN

تمام قابلیت‌های مرتبط با MasterDnsVPN متعلق به توسعه‌دهندگان اصلی آن است.

---

# لایسنس

MIT
