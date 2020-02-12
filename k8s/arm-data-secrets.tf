data "azurerm_key_vault_secret" "nginx-ingress-auth-file" {
    name = "nginx-ingress-auth-file"
    key_vault_id = data.azurerm_key_vault.secrets-kv.id
}

data "azurerm_key_vault_secret" "ddns-domain-name" {
    name = "ddns-domain-name"
    key_vault_id = data.azurerm_key_vault.secrets-kv.id
}

data "azurerm_key_vault_secret" "email" {
    name = "email"
    key_vault_id = data.azurerm_key_vault.secrets-kv.id
}

data "azurerm_key_vault_secret" "nexus-username" {
    name = "nexus-username"
    key_vault_id = data.azurerm_key_vault.secrets-kv.id
}

data "azurerm_key_vault_secret" "nexus-password" {
    name = "nexus-password"
    key_vault_id = data.azurerm_key_vault.secrets-kv.id
}

