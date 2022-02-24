/etc/sssd/sssd.conf:
  file.replace:
    - pattern: '(cache_credentials)+\W+\w+'
    - repl: 'cache_credentials = False'


krb5:
  file.replace:
    - name: /etc/sssd/sssd.conf
    - pattern: '(krb5_store_password_if_offline)+\W+\w+'
    - repl: 'krb5_store_password_if_offline = False'

restart_sssd:
  module.run:
    - name: service.restart
    - m_name: sssd


/etc/ssh/sshd_config:
  file.replace:
    - pattern: '(GSSAPIAuthentication)+\W+\w+'
    - repl: 'GSSAPIAuthentication no'
    - require: 
      - restart_sssd

restart sshd:
  module.run:
    - name: service.restart
    - m_name: sshd

Remove yum repo files:
  cmd.run:
    - name: rm -f /etc/yum.repos.d/*.bak
