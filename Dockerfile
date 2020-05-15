FROM python:alpine3.10

ARG VCS_REF
ARG BUILD_DATE

ENV TERRAFORM_VERSION=0.12.24 \
    GCLOUD_SDK_VERSION=292.0.0 \
    KUBE_VERSION=v1.18.2 \
    KUBESPRAY_RELEASE=release-2.13

ENV GCLOUD_SDK_FILE=google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    TERRAFORM_FILE=terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN apk --update add --virtual build-dependencies g++ libffi-dev build-base && \
    apk add --no-cache -U bash curl jq git openssh-client gcc make musl-dev libffi-dev openssl-dev openssl ca-certificates && \
    if [ ! -e /usr/bin/python ]; then ln -sf /usr/bin/python3 /usr/bin/python ; fi && \
    python3 -m ensurepip && \
    if [ ! -e /usr/bin/pip ]; then ln -s /usr/bin/pip3 /usr/bin/pip ; fi && \
    pip install --no-cache --upgrade pip setuptools wheel cffi

RUN curl -o /root/$GCLOUD_SDK_FILE https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/$GCLOUD_SDK_FILE && \
    curl -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$KUBE_VERSION/bin/linux/amd64/kubectl && \
    curl -o /root/$TERRAFORM_FILE https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/$TERRAFORM_FILE

WORKDIR /root

RUN unzip $TERRAFORM_FILE && \
    mv terraform /usr/local/bin && \
    rm $TERRAFORM_FILE && \
    tar xzf $GCLOUD_SDK_FILE && \
    /root/google-cloud-sdk/install.sh -q && \
    /root/google-cloud-sdk/bin/gcloud config set disable_usage_reporting true && \
    rm /root/${GCLOUD_SDK_FILE} && \
    chmod +x /usr/local/bin/kubectl && \
    git clone https://github.com/shmileee/kubespray.git && \
    cd kubespray && \
    git checkout ${KUBESPRAY_RELEASE} && \
    pip install -r requirements.txt && \
    pip install requests google-auth

ADD src/profile /root/.bashrc
ADD src/ansible.cfg /root/.ansible.cfg
ADD src/ansible.cfg /root/kubespray/ansible.cfg

WORKDIR /root/src

# Metadata
LABEL maintainer="Aleksandr Ponomarov <ponomarov.aleksandr@gmail.com>" \
      org.label-schema.url="https://github.com/shmileee/terraform-k8s-gce/" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url="git@github.com:shmileee/terraform-k8s-gce.git" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vcs-type="Git" \
      org.label-schema.docker.dockerfile="Dockerfile" \
      org.label-schema.docker.cmd="docker run -it -v ./src:/root/src -v ~/.ssh:/root/.ssh --name k8s-on-gce-toolset k8s-on-gce-toolset" \
      org.label-schema.description="Toolset for deploying Kubernetes cluster on GCE with Terraform and Ansible" \
      org.label-schema.usage="https://github.com/shmileee/terraform-k8s-gce/blob/master/README.md" \
      org.label-schema.schema-version="1.0"

ENTRYPOINT [ "/bin/bash" ]
