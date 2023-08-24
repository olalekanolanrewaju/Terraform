# Configure the Google Cloud provider
provider "google" {
  project = "cmp9140-26242493"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

# Define the virtual private cloud (VPC)
resource "google_compute_network" "vpc" {
  name                    = "my-network"
  auto_create_subnetworks = false  # Don't automatically create subnets
}

# Define the subnet within the VPC
resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnet"
  region        = "europe-west1"
  network       = google_compute_network.vpc.self_link
  ip_cidr_range = "10.0.0.0/16"
}

# Create 2 web server instances
resource "google_compute_instance" "web" {
  count        = 2
  name         = "web-server-${count.index}"
  machine_type = "n1-standard-1"
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"  # Debian 10 image
    }
  }

  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name
  }
}
# Define an HTTP health check for load balancing
resource "google_compute_http_health_check" "http_health_check" {
  name = "http-health-check"
}

# Define a target pool for the web servers to facilitate load balancing
resource "google_compute_target_pool" "web_target_pool" {
  name      = "web-target-pool"
  instances = google_compute_instance.web[*].self_link

  health_checks = [
    google_compute_http_health_check.http_health_check.name,
  ]
}

# Define a forwarding rule for directing HTTP traffic to the web server target pool
resource "google_compute_forwarding_rule" "web_forwarding_rule" {
  name       = "web-forwarding-rule"
  target     = google_compute_target_pool.web_target_pool.self_link
  port_range = "80"
}