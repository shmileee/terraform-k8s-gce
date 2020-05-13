#!/bin/sh

rm -f /root/.ssh/google_compute_engine*
ssh-keygen -q -P "" -f /root/.ssh/google_compute_engine

terraform init gce-provisioning

terraform apply -auto-approve -var "gce_zone=${GCLOUD_ZONE}" gce-provisioning