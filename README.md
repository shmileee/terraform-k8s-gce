# Kubernetes with Terraform and Kubespray on GCE

This project leverages Terraform, Ansible and Docker to automate the deployment of a minimalistic Kubernetes cluster on GCE.

## How to use

- Put your GCE credentials (`gce_creds.json`) in the `src` dir (See [GCloud account](#gcloud-account) for details on this file).
- Adapt `src/profile` to match your desired network, region, zone and project names.
- Run `make` to build a docker image.
- Run `make exec` to spawn a container with all required tools.
- Inside container, run `./create.sh` to bootstrap infrastructure with Terraform. Adjust `src/gce-provisioning` to suit your needs. 
- Run `./ansible.sh` to install HAProxy on bastion host and bootstrap Kubernetes cluster with Kubespray.

When you're done, run `./destroy.sh` to remove all GCE resources created with Terraform.

## GCloud account 

To interact with GCloud API service account is used. The `gce_creds.json` is your service account key file.
You can find more information on how to setup a service account [here](https://cloud.google.com/video-intelligence/docs/common/auth#set_up_a_service_account).

## Terraform topology

By default, Terraform will create DNS zone, network routers, 3 compute instances (1 bastion, 1 kube-master and 1 kube-node).

## Ansible inventory

Kubespray will use dynamic GCE inventory defined in `src/miscellaneous/inventory/inventory.gcp.yml`. Hosts are extracted during runtime, variables are merged with Kubespray `group_vars` and artificial static inventory (`src/miscellaneous/inventory/inventory.ini`). 