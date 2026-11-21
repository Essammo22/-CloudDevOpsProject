variable "vpc_id" {
  type = string

}
variable "subnet_id" {
  type = string

}
variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "ivolve-key"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}