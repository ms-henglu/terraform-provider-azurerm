
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124181816148700"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestkv-29rid"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "Delete",
      "Import",
      "Get",
      "ManageIssuers",
      "SetIssuers",
    ]

    key_permissions = [
      "Create",
    ]

    secret_permissions = [
      "Set",
    ]
  }
}

resource "azurerm_key_vault_certificate_issuer" "test" {
  name          = "acctestKVCI-221124181816148700"
  key_vault_id  = azurerm_key_vault.test.id
  account_id    = "test-account"
  password      = "test"
  provider_name = "DigiCert"

  org_id = "accTestOrg"
  admin {
    email_address = "admin@contoso.com"
    first_name    = "First"
    last_name     = "Last"
    phone         = "01234567890"
  }
}
