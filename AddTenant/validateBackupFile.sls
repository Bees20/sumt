{% set filePath = pillar['filePath'] %}

wait_for_file:
  file.exists:
    - name: {{ filePath }}
