provider "google" {
  project     = "gke-terraform-460420"
  region      = "europe-west1"
  credentials = file("~/.gcp/service-account.json")
}
