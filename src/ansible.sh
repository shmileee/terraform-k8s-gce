#!/bin/sh

inv_dir="/root/src/miscellaneous/inventory"

bastion_host_pub_ip=$(ansible-inventory -i ${inv_dir}/inventory.gcp.yml --host haproxy | jq '.ansible_host' -r)
bastion_host_pvt_ip=$(ansible-inventory -i ${inv_dir}/inventory.gcp.yml --host haproxy | jq '.ip' -r)

# wait while nginx is up and running on bastion
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' ${bastion_host_pub_ip})" != "200" ]]; do sleep 5; done

# let apk release locks: https://github.com/ansible/ansible/issues/51663
sleep 2m

# install haproxy
ansible-playbook -i ${inv_dir}/inventory.gcp.yml haproxy/haproxy-playbook.yml

# install kubernetes
cd /root/kubespray && ansible-playbook --become -i ${inv_dir}/inventory.gcp.yml -i ${inv_dir}/inventory.ini cluster.yml --flush-cache

# fix master ip on for kubectl
cd "${inv_dir}/artifacts" && sed -i "s/${bastion_host_pvt_ip}/${bastion_host_pub_ip}/g" admin.conf

chown -R 1001:1001 "${inv_dir}/artifacts" "${inv_dir}/credentials"