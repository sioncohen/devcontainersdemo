#!/bin/bash
# Start SSH daemon in the background
service ssh start -D

# Start JupyterLab
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password=''




