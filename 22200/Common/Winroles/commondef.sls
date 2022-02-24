{% import "./vars.sls" as commonbase %}

# Create log folder
Create_logfolder:
  file.directory:
    - name: {{ commonbase.log_folder }}
    - makedirs: True

Create_tempfolder:
  file.directory:
    - name: {{ commonbase.temp_folder }}
    - makedirs: True
