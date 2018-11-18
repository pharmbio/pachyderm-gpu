# Setting up Pachyderm on Vagrant
In this page we introduce how to run a set up a simple Minikube node using Vagrant, and starting `pachd`

## Prerequisites

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](https://www.vagrantup.com/)

## Firing up a Vagrant box

After cloning this repository, start the Vagrant box using the following command. Note that you should be under the directory where the `Vagrantfile` is located. 
```bash
> vagrant up --provision
```

## Setting up Minikube and pachd

First ssh into the Vagrant guest machine and invoke the following commands:
```bash
> vagrant ssh
> cd bootstrap
> sh setup.sh
> sh start-pachd.sh
```

## Accessing the Kubernetes dashboard

You can access the dashboard by starting a proxy server on Minikube and forwarding the traffic to the host via a ssh tunnel. Run the following commands from your local machine.

> **NOTE:** The private key can be found under the `.vagrant` directory, which is located at the same directory as the Vagrantfile. Make sure you add it to the key-chain.

```bash
> export PRIVATE_KEY=$(vagrant ssh-config | grep IdentityFile | cut -f 4 -d ' ')
> ssh-add $PRIVATE_KEY
> ssh -L 8001:127.0.0.1:8001 vagrant@localhost -p 2222 -i $PRIVATE_KEY
```

Once you have created the tunnel, execute the following command in the Vagrant guest host:

```bash
> sudo kubectl proxy
```

You can access the dashboard your local machine by simply:

```bash
> open http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/
```

