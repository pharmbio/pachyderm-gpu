# Start Pachyderm daemon
helm install -f /home/vagrant/tutorial/pachyderm-values.yaml --namespace pachyderm --name my-release stable/pachyderm