variable "kv_policies" {
  type = map(object({
    key_permissions         = optional(list(string))
    secret_permissions      = optional(list(string))
    certificate_permissions = optional(list(string))
  }))
  description = "Mapa polityk Key Vault, gdzie klucz to nazwa polityki, a wartość to obiekt z uprawnieniami"
}

variable "key_vault_id" {
  type        = string
  description = "ID Key Vault"
}

variable "tenant_id" {
  type        = string
  description = "Identyfikator dzierżawy Azure"
}

variable "object_id" {
  type        = string
  description = "Identyfikator obiektu (np. użytkownika lub grupy) dla polityki dostępu"
}