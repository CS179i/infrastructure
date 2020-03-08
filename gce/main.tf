provider "google" {
  credentials = file("credentials.json")
  project     = "opa-268409"
  region      = var.default-region
  zone        = var.default-zone
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
    network = "default"
    access_config {} // Ensure that this instance has an IP address.
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