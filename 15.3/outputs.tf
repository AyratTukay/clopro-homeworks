output "bucket_url" {
  value = "https://storage.yandexcloud.net/${yandex_storage_bucket.this.id}/linux.jpeg"
}

output "nlb_address" {
  description = "Public IP address of the Network Load Balancer"
  value       = one(one(yandex_lb_network_load_balancer.nlb.listener).external_address_spec).address
}


output "vm_external_ips" {
  description = "Public IP addresses of the instances"
  value       = [for instance in yandex_compute_instance_group.lamp_ig.instances : instance.network_interface[0].nat_ip_address]
}
