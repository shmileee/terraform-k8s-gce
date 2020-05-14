#!/bin/sh

terraform destroy \
    -var "gce_zone=${GCLOUD_ZONE}" \
    -var "gce_project=${GCLOUD_PROJECT}" \
    -var "gce_region=${GCLOUD_REGION}" \
    -var "gce_sa_email=${GCE_EMAIL}" \
    -var "gce_network=${GCLOUD_NETWORK}" \
    -var "gce_subnetwork=${GCLOUD_REGION}" \
    -force gce-provisioning/
