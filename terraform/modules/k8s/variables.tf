variable "ns" {
  type = string
}

variable "app_name" {
  type = string
}

variable "registry" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "container_port" {
  type = string
  default = 3000
}

variable "svc_port" {
  type = number
  default = 8080
}