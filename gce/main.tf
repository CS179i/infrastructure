provider "google" {
  credentials = file("credentials.json")
  project     = "opa-268409"
  region      = var.default-region
  zone        = var.default-zone
}

resource "google_compute_network" "opa-net" {
  name = "opa-net"
}

resource "google_compute_subnetwork" "opa-net-us-west2" {
  name          = "opa-net-us-west2"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.default-region
  network       = google_compute_network.opa-net.self_link
}

resource "google_compute_firewall" "default" {
  name    = "default-firewall"
  network = google_compute_network.opa-net.name

  allow {
    protocol = "icmp"
  }

  // Web traffic.
  allow {
    protocol  = "tcp"
    ports     = ["80", "443"]
  }

  // SSH.
  allow {
    protocol  = "tcp"
    ports     = ["22"]
  }
}

resource "google_compute_instance" "backend" {
  name          = "backend"
  machine_type  = "n1-standard-1"
  zone          = var.default-zone

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable-80-12739-91-0"
    }
  }

  network_interface {
    network     = "opa-net"
    subnetwork  = "opa-net-us-west2"
    
    access_config {} // Ensure that this instance has an IP address.
  }

  metadata = {
    user-data = file("cloud-config") // Cloud init configuration.
  }

  service_account {
    email = var.service-account-email
    scopes = ["cloud-platform", "userinfo-email", "https://www.googleapis.com/auth/firebase.database"]
  }
}

resource "google_dns_managed_zone" "prod" {
  name      = "prod"
  dns_name  = "opa.social."
}

resource "google_dns_record_set" "api" {
  name          = "api.${google_dns_managed_zone.prod.dns_name}"
  managed_zone  = google_dns_managed_zone.prod.name
  type          = "A"
  ttl           = 5

  // IP address of google compute instance.
  rrdatas = [
    google_compute_instance.backend.network_interface.0.access_config.0.nat_ip
  ]
}