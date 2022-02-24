update_pkg:
  pkg.uptodate:
    - refresh : True
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

