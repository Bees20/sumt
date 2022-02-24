replace_ntpserver:
  file.line:
    - name: /etc/ntp.conf
    - mode: replace
    - match: ^server.*
    - content: server {{ salt['pillar.get']('ntpServer') }}


Remove external ntp config :
  cmd.run:
    - name: sed -i '/centos.pool.ntp.org/d' /etc/ntp.conf


