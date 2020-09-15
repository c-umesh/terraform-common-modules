variable "server_port" {
  description = "The port server will use for HTTP requests"
  type = number
  default = 8080
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type =string
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "The max number of EC2 Instances in the ASG"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
}