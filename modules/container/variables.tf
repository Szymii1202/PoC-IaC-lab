variable "containers" {
    type        = map(object({
      container_access_type = optional(string, "private")
    }))
    description = "Mapa kontenerów, gdzie klucz to nazwa kontenera, a wartość to typ dostępu (private, blob, container)"
}

variable "storage_account_id" {
  type        = string
  description = "ID konta magazynu"
}