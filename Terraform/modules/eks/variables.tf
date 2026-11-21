variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "ivolve-eks"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS"
  type        = list(string)
}

