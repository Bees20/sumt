Modify minion config:
  file.replace:
    - name: 'C:\salt\conf\minion'
    - pattern: 'multiprocessing: false'
    - repl: 'multiprocessing: True'
