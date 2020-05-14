terraform {
  backend "gcs" {
    bucket      = "tf-state-gameflare-test"
    prefix      = "terraform/state"
    credentials = "gce_creds.json"
  }
}
