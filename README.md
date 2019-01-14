# Scientific workflows with Pachyderm
In this page we introduce how to run a simple Tensorflow GPU-enabled pipeline using Pachyderm

## Relevant sources of information

- [Pachyderm Helm Chart](https://github.com/kubernetes/charts/tree/master/stable/pachyderm) A Helm Chart for deploying Pachyderm on Kubernetes as a service
- [Pachyderm Documentation](http://docs.pachyderm.io/en/v1.7.3/index.html) Official documentation of Pachyderm
- [Kubernetes cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/) Basic Kubernetes client commands
- [NVIDIA docker](https://github.com/NVIDIA/nvidia-docker) NVIDIA Docker runtime environment source

## Prerequisites

- A Kubernetes cluster with dynamic provisioning of volumes (v 1.10+)
- Pachyderm 1.8.2+
- [NVIDIA drivers via package manager](https://www.nvidia.com/object/unix.html) or via [containers](https://github.com/NVIDIA/nvidia-docker/wiki/Driver-containers-(EXPERIMENTAL))
- [nvidia-docker2 setup on your machine](https://github.com/NVIDIA/nvidia-docker)
- [NVIDIA device plugin for Kubernetes](https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v1.10/nvidia-device-plugin.yml)

## Deploy Pachyderm on Kubernetes

> **NOTE:** You can skip this step if you followed the instructions for setting up a Vagrant box. 

Deploy Helm (Kubernetes Package Manager) on your newly instantiated cluster:  
```bash
> kubectl -n kube-system create sa tiller
> kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
> helm init --service-account tiller
```
Deploy Pachyderm as a service on your cluster:
```bash
> helm install --namespace pachyderm --name my-release stable/pachyderm
```

Please note that the last two commands may take a little while to complete. Take a look at how Helm works. What are each of the arguments that we pass to the install command?

## Hands-on with Pachyderm

### Useful information
The most common way to interact with Pachyderm is by using the Pachyderm Client (pachctl). You can explore the different commands available by using:
```bash
> pachctl --help
```
And if you need more information about a particular command please use:
```bash
> pachctl <name of the command> --help
```

### Add data to the Pachyderm File System (PFS)

A repo is the highest level data primitive in Pachyderm. They should be dedicated to a single source of data such as the input from a particular tool. Examples include training data for an ML model or genome annotation data.
Here we will create a single repo which will serve as input for the first step of the workflow:
```bash
> pachctl create-repo data
```
You can push data into this repository using the put-file command. This will create a new commit, add data, and finish the commit. Explore further on how commits work. First navigate to the folder with the data you want to upload: 
```bash
> cd ./<my/folder>
```
Now push the data into the repository you created in the previous step:
```bash
> pachctl put-file data master -c -r -p <number of files to upload in parallel> -f .
```
This will create a new commit on the repository including the data we previously downloaded.

### Running a Pachyderm pipeline

Once your data is in the repository, you are ready to start a bunch of pipelines cranking through data in a distributed fashion. Pipelines are the core processing primitive in Pachyderm and they’re specified with a JSON encoding. Explore the pipelines folder and find out what the input field means:
```JSON
 "input": {
    "atom": {
      "repo": "",
      "glob": ""
    }
  }
```
The image used in this pipeline stage is a customised tensorflow image derived from `tensorflow/tensorflow:1.12.0-gpu` which was defined in the Dockerfile under the `docker` directory. The `gpu.py` script simply prints out information about the available CPU/GPU devices to perform the computation, and redirect it to a output file. Also, we print the output of a `ls` command and redirect it to a different file.
```JSON
  "transform": {
    "image": "novella/tensorflow-pachyderm:gputest",
    "cmd": [ "/bin/bash" ],
    "stdin": [
      "python /code/gpu.py > /pfs/out/output-logs.txt",
      "ls /pfs/data > /pfs/out/input-data.txt"
    ]
  },
  ```
Currently Pachyderm does support the latest NVIDIA Kubernetes drivers. Here it is shown how to limit GPU resources used by the pipeline:

```JSON
  "resource_limits": {
    "memory": "2.0G",
    "gpu": {
      "type": "nvidia.com/gpu",
      "number": 2
    }
  },
```

You can run a pipeline stage using:
```bash
> pachctl create-pipeline -f <JSON file>
```

> **NOTE I:** Does your Kubernetes cluster have access to GPU resources? If not, you should either remove the GPU request/limit specifications from your pipeline or install the NVIDIA drivers on your cluster. You can run the following command to verify this. If it does have access, you should see an output similar to the following: `nvidia.com/gpu: "10"`.

```bash
> kubectl get nodes -o yaml | grep gpu 
```
What happens after you create a pipeline? Creating a pipeline tells Pachyderm to run your code on every finished commit in a repo as well as all future commits that happen after the pipeline is created. Our repo already had a commit, so Pachyderm automatically launched a job (Kubernetes pod) to process that data. This first time it might take some extra time since it needs to download the image from a container image registry. You can view the pipeline status and its corresponding logs using:
```bash
> pachctl list-pipeline
> pachctl get-logs --pipeline <name-of-the-pipeline>

```
And explore the different jobs and corresponding pods in your Kubernetes cluster via:
```bash
> pachctl list-job
> kubectl get pods -o wide -n pachyderm
```
Try changing some parameters such as the parallelism specification, resource specification and glob pattern. What is happening? How many pods are scheduled? Play with the parameters and try to understand what happens. You can learn about the different settings in the Pachyderm Documentation.

You can re-run the pipeline with a new pipeline definition (new parameters etc) like this:
```bash
> pachctl update-pipeline -f <JSON file> --reprocess
```
After you run the pipeline, the resulting files generated by the pipeline stage will be saved in the `data` repository. You can download the file simply by using `get-file`:
```bash
> pachctl get-file mypipeline master output-logs.txt > ./output-logs.txt
```
The <commit-id> is easily obtainable by checking the most recently made commit in the `data` repository using:
```bash
> pachctl list-commit <repository>
```
Also, the <path-to-file> can be obtained by checking the list of files outputted to the `data` repository at a specific branch. To which branch does Pachyderm make commits by default?
```bash
> pachctl list-file <repository> master
```

### Data versioning in Pachyderm

Pachyderm uses a Data Repository within its File System. This means that it will keep track of different file versions over time, like Git. Effectively, it enables the ability to track the provenance of results: results can be traced back to their origins at any time point.

Pipelines automatically process the data as new commits are finished. Think of pipelines as being subscribed to any new commits on their input repositories. Similarly to Git, commits have a parental structure that tracks which files have changed.

Let’s create a new commit in a parental structure. To do this we will simply do ome more `put-file` command with `-c` and by specifying master as the branch, it will automatically parent our commits onto each other. Branch names are just references to a particular `HEAD` commit.
```bash
> cd ./<my/folder/with/more/data>
```
```bash
> pachctl put-file data master -c -r -p <number of files to upload in parallel> -f .
```
Did any new job get triggered? What data is being processed now? All available data or just new data? Explore which new commits have been made as a result of the new input data. 
```bash
> pachctl list-commit data
```
You can inspect additional information about a job like this:
```bash
> pachctl inspect-job <job-id> --raw
```
