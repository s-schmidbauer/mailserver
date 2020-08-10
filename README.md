# ansible role for configuring openbsd based mail server

`tested with: 6.7`

# Setup
* Configure all name records with help of scripts
* Configure spf, dmarc, dkim
* Configure inventory: `ansible_user=root ansible_ssh_password=secret`
* Get root pass and put it in inventory

## Collect mail information
* rdns.yml
* spf.yml
* dkim.yml
* dmarc.yml
* tlsa.yml

Run playbooks in below order.

Set `update: true`
Set `httpd_use_tls: false`

# Prep
Configure mail domain, fqnd and IP settings.
Specify two list: users and admins
Users and Admins provide passwords by hash.
Admins have ssh keys to connect
Authorized trusted IPs can manage and monitor.

## Base
* system.yml
* syspatch.yml
* ssh.yml
* pf.yml
* httpd.yml
* acme-client.yml
* httpd.yml

Configure inventory to no longer use passwords: `ansible_user=root ansible_ssh_private_key=~/.ssh/id_ecdsa`

Enable use tls again: `httpd_use_tls: true`
Set `update: false`

## Mail
* rspamd.yml
* smtpd.yml
* dovecot.yml
* sieve.yml
