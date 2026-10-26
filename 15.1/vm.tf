
#считываем данные об образе ОС
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

#--------------------vm-public----------------------------------
resource "yandex_compute_instance" "public" {
  name        = "vm-public" #Имя ВМ в облачной консоли
  hostname    = "public" #формирует FDQN имя хоста, без hostname будет сгенрировано случаное имя.
  platform_id = "standard-v3"
  allow_stopping_for_update = true
  zone        = var.default_zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8e5jmcvep85j33nt0e"
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
  }

  scheduling_policy {preemptible = true }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
  }
}

#--------------------vm-private----------------------------------
resource "yandex_compute_instance" "private" {
  name        = "vm-private"
  hostname    = "private"
  platform_id = "standard-v3"
  allow_stopping_for_update = true
  zone        = var.default_zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8e5jmcvep85j33nt0e"
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.private.id
    nat        = false
  }
  scheduling_policy {preemptible = true }
}
