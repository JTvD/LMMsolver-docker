# R2PY docker
Some functions are only available in R, like the [LMMsolver](https://biometris.github.io/LMMsolver/) developed by biometris at WUR.
This examples shows how the LMM solves can be called from python running inside a docker container. 
Preparing it as a building block for automated/advanced data processing pipelines.

## Docker commands
Build the container: `docker build -t r2pydocker -f Dockerfile .`  
Run the container: `docker run  -m2g r2pydocker`   
Or interactively: `docker run -it -m2g r2pydocker` 
Inside the docker navigate to the `src` folder and enter `python3 main.py` to run the example.