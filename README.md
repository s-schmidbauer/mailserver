# OpenBSD based mail server (smtpd, dovecot, rspamd, sieve).
# Setup using ansible.

`Tested with: OpenBSD 7.5 and ansible 2.16.5 on python 3.12.2`

For support, contact [www.schmidbauer.cz](https://www.schmidbauer.cz)

## General Setup
* Configure a new server running OpenBSD 7.5 (i. e. [www.vultr.com](https://www.vultr.com/?ref=7294151) )
* Python 3 on new client and server
* Setup your DNS for: A, AAAA and reverse records
* Later, once tested and working fine you can also create an MX records for your domain
* Make sure the new server is ssh-able
* Have ansible >=2.8 on your laptop

Run playbooks in below order.

## Prep
* Users, Admins and a `mailadmin` user provide passwords by hash. Hash the passwords you want to use.
* Admins have ssh keys to connect. They are copied from your workstation.
* Authorized, trusted IPs can manage and monitor. Add them to `pf_trusted_hosts`
* Normal visitors can do HTTP and HTTPs as well as known mail ports
* Prepare an inventory for your server like so
```
[all_hosts]
1.2.3.4 ansible_python_interpreter=/usr/local/bin/python3 ansible_port=22 ansible_user=root ansible_ssh_private_key=~/.ssh/id_ecdsa
```
* ..Or create an ansible inventory using: `ansible_user=root ansible_ssh_password=secret`  .. if you need to use root and a password.

## Customize
Set parameters in a hosts file (like `host_vars/mail.schmidbauer.cz` or set them globally in `group_vars/all.yml`)
* Configure `mail_domain`.
* Configure `fqdn`
* Configure IP settings, if you need manual config
* Configure `Admins`, `Users` along with their password hashes
* Configure `mailadmin` password hash. The user is used to provide admin-access to Mailboxes (WIP)

## Base
Run below playbooks in order
* system.yml ( `ansible-playbook -i inventory system.yml` )
* syspatch.yml ( `ansible-playbook -i inventory syspatch.yml -e "update=true"` )
* ssh.yml ( `ansible-playbook -i inventory ssh.yml` )
* pf.yml ( `ansible-playbook -i inventory pf.yml` )
* from here on, create your A and AAAA for allowing cert creation
* httpd.yml ( `ansible-playbook -i inventory httpd.yml -e "httpd_use_tls=false" -e "httpd_use_lets_encrypt=true"` )
* acme-client.yml ( `ansible-playbook -i inventory acme-client.yml` )
* httpd.yml ( `ansible-playbook -i inventory httpd.yml -e "httpd_use_tls=true" -e "httpd_use_lets_encrypt=true"` )
* Configure inventory to no longer use passwords: `ansible_user=puffy ansible_ssh_private_key=~/.ssh/id_ecdsa`

## Mail
Run below playbooks in order
* rspamd.yml ( `ansible-playbook -i inventory rspamd.yml` )
* dkim.yml ( `ansible-playbook -i inventory dkim.yml` )
* smtpd.yml ( `ansible-playbook -i inventory smtpd.yml` )
* dovecot.yml ( `ansible-playbook -i inventory dovecot.yml` )
* sieve.yml ( `ansible-playbook -i inventory sieve.yml` )
* mta-sts.yml ( `ansible-playbook -i inventory mta-sts.yml` )

# And finally
* Configure SPF, DMARC, DKIM and more later with help of:
* `dns-setup.yml` ( `ansible-playbook -i inventory dns-setup.yml` )
* ..  It can be tough / annoying / confusing. Don't give up.
* Optionally: Restore a Maildir backup to the local home folder of your user

## Setup your mail client

### Incoming:
* IMAP
* mail.schmidbauer.cz
* Port 143
* STARTSSL
* Login: password
* User: stefan

### Outgoing:
* SMTP
* mail.schmidbauer.cz
* Port 587
* STARTSSL
* Login: password
* User: stefan

## Big shoutouts to
* The guys working on [OpenBSD](https://www.openbsd.org)
* [Gilles Chehade](https://www.poolp.org) for his amazing work in `smtpd`
* [horia](https://github.com/vedetta-com) for this amazing efforts with `caesonia` and `vedetta`
