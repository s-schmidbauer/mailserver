domain={{ mail_domain }}
ip=$(dig -t A +short {{ fqdn }})
ip6=$(dig -t AAAA +short {{ fqdn }})
resolver=8.8.8.8
selector=$(date +"%Y%m%d")
pubkey=$(sed -e '1d' -e '$d' "{{ dkim_key_folder }}/{{ mail_domain }}.pub" | tr -d '\n')
#tlsa=$(ldns-dane -r $resolver create {{ fqdn }} 443 {{ tlsa_usage }} | cut -d' ' -f4)
tlsa256=$(openssl x509 -noout -pubkey -in /etc/ssl/{{ fqdn }}.fullchain.pem | openssl rsa -pubin -outform der 2>/dev/null | sha256)
tlsa512=$(openssl x509 -noout -pubkey -in /etc/ssl/{{ fqdn }}.fullchain.pem | openssl rsa -pubin -outform der 2>/dev/null | sha512)

echo "Forward record:"
host {{ fqdn }}
echo "\n"

echo "Reverse record:"
host $ip
host $ip6
echo "\n"

echo "DKIM record for $domain with selector $selector:"
dkim=$(echo "v=DKIM1; k=rsa; p=$pubkey;")
echo $selector'._domainkey TXT ' $dkim
echo "- when DKIM key/cert is renewed make sure to update /etc/rspamd/local.d/dkim_signing.conf and restart rspamd!"
echo "\n"

echo "DANE(TLSA) records for {{ fqdn }} for STARTTLS ports {{ tlsa_ports }}:"
echo tlsa._dane.{{ host }}' TLSA ' 3 1 1 $tlsa256
echo tlsa._dane.{{ host }}' TLSA ' 3 1 2 $tlsa512
for p in {{ tlsa_ports }}; do echo _$p._tcp.{{ host }}' CNAME ' tlsa._dane.{{ fqdn }} ; done
echo "\n"

echo "DMARC record for $domain:"
echo "_dmarc TXT v=DMARC{{ dmarc_version }};p={{ dmarc_policy }};pct={{ dmarc_percent }};rua=mailto:{{ dmarc_rua_contact }};"
echo "\n"

echo "SPF record for $domain:"
echo "@ TXT v=SPF{{ spf_version }} mx:{{ mail_domain }} -{{ spf_scope }} "
echo "\n"

echo "SSHFP records for {{ fqdn }}:"
ssh-keygen -r {{ fqdn }}
echo "\n"
