resource "google_compute_instance" "nfs" {
  depends_on          = [google_compute_instance.bastion]
  count               = 1
  name                = "nfs-${count.index + 1}"
  machine_type        = "e2-micro"
  can_ip_forward      = true
  deletion_protection = false

  tags = [var.gce_network, "nfs", "no-ip"]

  boot_disk {
    initialize_params {
      type  = "pd-standard"
      image = "ubuntu-os-cloud/ubuntu-minimal-1804-bionic-v20200220"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnetwork.self_link
    // network_ip = "10.240.0.3${count.index}"

    // access_config {
    //   // Ephemeral IP
    // }
  }

  service_account {
    email  = var.gce_sa_email
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }

  metadata = {
    sshKeys        = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
    enable-oslogin = false
  }

  metadata_startup_script = file("gce-provisioning/startup-nfs.sh")
}

resource "google_dns_record_set" "nfs" {
  count = 1
  name  = "${element(google_compute_instance.nfs[*].name, count.index)}.${google_dns_managed_zone.private-zone.dns_name}"
  type  = "A"
  ttl   = 300

  managed_zone = google_dns_managed_zone.private-zone.name

  rrdatas = [element(google_compute_instance.nfs[*].network_interface[0].network_ip, count.index)]
}

resource "google_compute_disk" "master-addl-data-disk-" {
  count = 1
  name  = "master-addl-data-disk-${count.index + 1}"
  type  = "pd-standard"
  zone  = var.gce_zone
  size  = "50"
}

resource "google_compute_instance" "master" {
  count                     = 1
  name                      = "master-${count.index + 1}"
  depends_on                = [google_compute_instance.bastion]
  machine_type              = "n1-standard-2"
  can_ip_forward            = true
  deletion_protection       = false
  allow_stopping_for_update = true

  tags = [var.gce_network, "no-ip", "kube-master", "etcd"]

  boot_disk {
    initialize_params {
      size  = 50
      type  = "pd-standard"
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  attached_disk {
    source      = element(google_compute_disk.master-addl-data-disk-.*.self_link, count.index + 1)
    device_name = element(google_compute_disk.master-addl-data-disk-.*.name, count.index + 1)
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnetwork.self_link
    // network_ip = "10.240.0.1${count.index}"
    // 
    // access_config {
    //   // Ephemeral IP
    // }
  }
  service_account {
    email  = var.gce_sa_email
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }

  metadata = {
    sshKeys        = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
    enable-oslogin = false
  }

  metadata_startup_script = file("gce-provisioning/startup-node.sh")
}

resource "google_compute_disk" "node-addl-data-disk-" {
  count = 1
  name  = "node-addl-data-disk-${count.index + 1}"
  type  = "pd-standard"
  zone  = var.gce_zone
  size  = 50
}

resource "google_compute_instance" "node" {
  count                     = 1
  name                      = "node-${count.index + 1}"
  depends_on                = [google_compute_instance.bastion]
  machine_type              = "n1-standard-2"
  can_ip_forward            = true
  deletion_protection       = false
  allow_stopping_for_update = true

  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  tags = [var.gce_network, "no-ip", "kube-node"]

  boot_disk {
    initialize_params {
      size  = 50
      type  = "pd-standard"
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  attached_disk {
    source      = element(google_compute_disk.node-addl-data-disk-.*.self_link, count.index)
    device_name = element(google_compute_disk.node-addl-data-disk-.*.name, count.index)
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnetwork.self_link
    // network_ip = "10.240.0.1${count.index}"
    // 
    // access_config {
    //   // Ephemeral IP
    // }
  }

  service_account {
    email  = var.gce_sa_email
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }

  metadata = {
    sshKeys        = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
    enable-oslogin = false
  }

  metadata_startup_script = file("gce-provisioning/startup-node.sh")
}
