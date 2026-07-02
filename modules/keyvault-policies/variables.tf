variable "kv_policies" {
  type = map(object({
    key_permissions         = optional(list(string))
    secret_permissions      = optional(list(string))
    certificate_permissions = optional(list(string))
  }))
  description = "Map of Key Vault policies, where the key is the policy name, and the value is an object with permissions"
}

variable "key_vault_id" {
  type        = string
  description = "ID of the Key Vault"
}

variable "tenant_id" {
  type        = string
  description = "Tenant ID of the Azure AD"
}

variable "object_id" {
  type        = string
  description = "Object ID of the user or group for the access policy"
}