Copy SQL scripts:
  file.recurse:
    - name: "c:\\Temp\\DB_TemplateScripts"
    - source: salt://files/DB_TemplateScripts
    - makedirs: true
    - include_empty: True
