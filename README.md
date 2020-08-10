# ansible role for configuring OpenBSD based mail server

`Tested with: OpenBSD 6.7`

# Setup
* Configure a new server
* Your DNS for: A, AAAA and reverse records
* Configure ansible inventory using: `ansible_user=root ansible_ssh_password=secret`
* (Or skip that step if your provider places a pubkey for you)
* Get root pass and put it in inventory

Run playbooks in below order.

# Prep
* Configure mail domain.
* Configure FQDN and IP settings of your new server
* Specify two list in `all.yml`: `users` and `admins`
* In `all.yml`, set `update: true`
* In `all.yml`, set `httpd_use_tls: false` (needed until Let's Encrypt step is done)
* Users and Admins provide passwords by hash.
* Admins have ssh keys to connect. They are copied from your workstation.
* Authorized, trusted IPs can manage and monitor.

## Base
Run below playbooks in order
* system.yml
* syspatch.yml
* ssh.yml
* pf.yml
* httpd.yml
* acme-client.yml
* httpd.yml (yes, again.)

Configure inventory to no longer use passwords:
`ansible_user=root ansible_ssh_private_key=~/.ssh/id_ecdsa`

Enable use tls again: `httpd_use_tls: true`
Set `update: false`

## Mail
* rspamd.yml
* smtpd.yml
* dovecot.yml
* sieve.yml

# And finally
* Configure SPF, DMARC, DKIM and more later with help of `dns-setup.yml`
* Restore a Maildir backup to the local home folder of your user
