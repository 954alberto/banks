variable "docker_tag" {
  default     = "0.1.8"
  description = "Version tag of docker images"
}

variable "project_name" {
  default     = "banks"
  description = "Name of the project, this will be used for the ECR, lambda, and few other services."
}

variable "project_subdomain" {
  default     = "tmnl"
  description = "Subdomain usedfor the project."
}

variable "project_domain_name" {
  default     = "crashzone.link"
  description = "Domain name used for the project"
}

variable "environment" {
  default     = "tst"
  description = "Target environment, values can be dev, tst, acc or prd."
}
