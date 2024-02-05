variable "ns" {
  type = string
  description = "Namespace"
}

variable "app_name" {
  type = string
  description = "Name of the application"
}

variable "registry" {
  type = string
  description = "Name of the registry/repository"
}

variable "image_tag" {
  type = string
  description = "Tag of the docker image"
}

variable "container_port" {
  type = string
  default = 3000
  description = "Port exposed by the container"
}

variable "svc_port" {
  type = number
  default = 8080
  description = "Port exposed by the service"
}