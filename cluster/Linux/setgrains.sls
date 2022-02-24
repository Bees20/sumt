Set cluster grains:
  module.run:
    - name: grains.setval
    - key: uda_cluster
    - val: {{ pillar['ClusterName'] }} 
