terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.243"
    }
  }
  required_version = ">=1.5.0"
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone = var.zone
  service_account_key_file = file("~/.authorized_key.json")
}
