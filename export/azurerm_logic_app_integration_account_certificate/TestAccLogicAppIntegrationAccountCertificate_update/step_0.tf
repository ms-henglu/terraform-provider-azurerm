

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azuread_service_principal" "test" {
  display_name = "Azure Logic Apps"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-240105061034190918"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestkv-kd3vc"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_key_vault_access_policy" "test1" {
  key_vault_id = azurerm_key_vault.test.id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign",
    "GetRotationPolicy"
  ]

  secret_permissions = [
    "Get",
    "Set",
  ]

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azuread_service_principal.test.object_id
}

resource "azurerm_key_vault_access_policy" "test2" {
  key_vault_id = azurerm_key_vault.test.id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign",
    "GetRotationPolicy"
  ]

  secret_permissions = [
    "Get",
    "Set",
  ]

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_key" "test" {
  name         = "acctestkvkey-kd3vc"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  depends_on = [azurerm_key_vault_access_policy.test1, azurerm_key_vault_access_policy.test2]
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctestia-240105061034190918"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}


resource "azurerm_logic_app_integration_account_certificate" "test" {
  name                     = "acctest-iac-240105061034190918"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name
  public_certificate       = "MIICsjCCAZoCCQCMdt7DvygPtDANBgkqhkiG9w0BAQsFADAbMRkwFwYDVQQDDBBhcGkudGVycmFmb3JtLmlvMB4XDTE4MDcwNTEwMzMzMFoXDTI4MDcwMjEwMzMzMFowGzEZMBcGA1UEAwwQYXBpLnRlcnJhZm9ybS5pbzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKQW332Ol28CsidAheD1aL9Ul8JWnKLdaVxKZ3ssl5CXjPDOmM7IXk0SgbQnUC8lIlPFZiDGbQ1sB6OTMun6ZZ4ipLp80dtl0roCLtCnDQOBGzCNArCYAoXRurjkXEY7tpD0wwtU72+37h3HQ4g0VS6VItJCqJ9QADV+HO2ZWuZTez70MhoL6OLfZP7HGYdJDKgfEVNF5XlbVzNAGkDIJFdhjNxyGGu5Nfsm1pfQhAyunkk7JVamjUg5IojRdo63IS9wwzMOdeGSAbBcsJfYeCfVg2kupR8q0TmZ+x93RmmOlbSi66kEYxRzZ9YCQeHJmn1YfJ92BpCUiy9A6Z1iaKUCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAJ7JhlecP7J48wI2QHTMbAMkkWBv/iWq1/QIF4ugH3Zb5PorOv+NfhQ0LlWiw/SzN8Ae95vUixAGYHMSa28oumM5K1OsqKEkVIo1AoBH8nBz+VcTpRD/mHXotAHPAZt9j5LqeHX+enR6RbINAf3jn+YU3MdVe0MsADdFASVDfjmQP2R7o9aJb/QqOg3bZBWsiBDEISfyaH2+pgUM7wtwEoFWmEMlgjLK1MRBs1cDZXqnHaCd/rs+NmWV9naEu7x5fyQOk4HozkpweR+Jx1sBlTRsa49/qSHt/6ULKfO01/cTs4iF71ykXPbh3Kj9cI2uo9aYtXkxkhKrGyUpA7FJqWw=="

  metadata = <<METADATA
    {
        "foo": "bar"
    }
METADATA

  key_vault_key {
    key_name     = azurerm_key_vault_key.test.name
    key_vault_id = azurerm_key_vault.test.id
    key_version  = azurerm_key_vault_key.test.version
  }
}
