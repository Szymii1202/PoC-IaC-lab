variable "containers" {
    type        = map(object({
      container_access_type = optional(string, "private")
    }))
    description = "Map of containers with their access types. The key is the container name, and the value is an object containing the access type."
}

variable "storage_account_id" {
  type        = string
  description = "ID of the storage account"
}