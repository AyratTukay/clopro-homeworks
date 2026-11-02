variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "bucket_name" {
  type = string
}

variable "local_image_path" {
  type = string
}

variable "lamp_image_id" {
  type = string
  default = "fd827b91d99psvq5fjit"
}

variable "instance_group_size" {
  type = number
  default = 3
}

variable "public_cidr" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network name"
}

variable "public_subnet_name" {
  type        = string
  default     = "public"
  description = "VPC subnet_public name"
}

