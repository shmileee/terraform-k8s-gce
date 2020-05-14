#!/bin/sh

terraform destroy -var "gce_zone=${GCLOUD_ZONE}" -force gce-provisioning/
