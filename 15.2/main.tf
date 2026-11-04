# 1. Object Storage
resource "yandex_storage_bucket" "this" {
  bucket = var.bucket_name
  anonymous_access_flags {
    read = true
    list = false
  }
}

resource "yandex_storage_object" "image" {
  bucket = yandex_storage_bucket.this.id
  key    = "image.jpeg"
  source = var.local_image_path
  content_type = "image/jpeg"
  acl          = "public-read"
}

# 2. Сеть
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "public" {
  name           = var.public_subnet_name
  zone           = var.zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.public_cidr
}

# 3. Security Groups
resource "yandex_vpc_security_group" "vm-sg" {
  name        = "vm-sg"
  network_id  = yandex_vpc_network.develop.id
  
  ingress {
    protocol          = "TCP"
    port              = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"] 
  }

   ingress {
    protocol          = "TCP"
    port              = 80
    v4_cidr_blocks    = ["198.18.235.0/24", "198.18.248.0/24"]
    description       = "Разрешение healthcheck балансировщика"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = -1
  }
}

# 4. Instance Group
resource "yandex_compute_instance_group" "lamp_ig" {
  name               = "lamp-instance-group"
  service_account_id = data.yandex_iam_service_account.sa_ig.id
  
  instance_template {
    platform_id = "standard-v3"
    resources {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
    boot_disk {
      initialize_params {
        image_id = var.lamp_image_id
        size     = 10
        type     = "network-hdd"
      }
    }
    network_interface {
      subnet_ids         = [yandex_vpc_subnet.public.id]
      nat                = true
      security_group_ids = [yandex_vpc_security_group.vm-sg.id]
    }
    metadata = {
      user-data = templatefile("./cloud-init.yaml", {
        bucket_name = yandex_storage_bucket.this.id
      })
      private_ui_access-method = "os-login"
      enable-oslogin           = "true"
    }
  }

  scale_policy {
    fixed_scale {
      size = var.instance_group_size
    }
  }

  allocation_policy {
    zones = [var.zone]
  }

  deploy_policy {
    max_unavailable = 0
    max_expansion   = 1
  }

  load_balancer {
    target_group_name = "lamp-nlb-tg"
  }

  health_check {
    http_options {
      port = 80
      path = "/"
    }
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

data "yandex_iam_service_account" "sa_ig" {
  name = "editor"
}

# 5. Балансировщик
resource "yandex_lb_network_load_balancer" "nlb" {
  name               = "lamp-nlb"
  deletion_protection = "false"
  listener {
    name = "http-listener"
    port = 80
    target_port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp_ig.load_balancer[0].target_group_id
    healthcheck {
      name = "http-check"
      interval = 5
      timeout = 3
      unhealthy_threshold = 2
      healthy_threshold = 5
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}
