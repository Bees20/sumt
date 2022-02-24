{% set version = salt['cmd.shell']('salt-call -V | grep -w Python').split(".")[0] | last %}


{% if version == "3" %}

Validated:
  test.succeed_without_changes

{% else %}

Validated:
  test.fail_without_changes

{% endif %}

