{% import "./Connectionvars.sls" as base %}

Insert Role Template Into CMDB:
  module.run:
    - name: cmdb_lib3.insertRoleTemplate
    - connect: {{ base.connect }}
    - datacenter: "{{ pillar['datacenter'] }}"
    - package: "{{ pillar['package'] }}"
    - role: "{{ pillar['role'] }}"
    - templateName: "{{ pillar['templateName'] }}"
    - templateDescription: "{{ pillar['templateDesc'] }}"
