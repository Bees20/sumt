Create Snapshot Folder:
  file.directory:
    - name: "s:\\mssql\\snapshots"
    - makedirs: True
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10
