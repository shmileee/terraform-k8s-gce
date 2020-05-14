#!/bin/sh

terraform init -reconfigure gce-provisioning

terraform apply -auto-approve -var "gce_zone=${GCLOUD_ZONE}" gce-provisioning
