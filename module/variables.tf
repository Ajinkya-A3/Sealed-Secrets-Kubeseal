variable "namespace" {
  description = "The namespace to deploy the sealed secrets controller"
  default     = "sealed-secrets"
}

variable "chart_version" {
    description = "The version of the sealed-secrets helm chart to deploy"
    default     = "2.18.0"
  
}

variable "values_path" {
    description = "Path to the values.yaml file for the sealed-secrets helm chart"
    default     = "./values-sealed-secrets.yaml"
  
}