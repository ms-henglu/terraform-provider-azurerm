
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024712217869"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestkv-ezn8l"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "delete",
      "import",
      "get",
      "manageissuers",
      "setissuers",
    ]

    key_permissions = [
      "create",
    ]

    secret_permissions = [
      "set",
    ]
  }
}

resource "azurerm_key_vault_certificate_issuer" "test" {
  name          = "acctestKVCI-211210024712217869"
  key_vault_id  = azurerm_key_vault.test.id
  provider_name = "OneCertV2-PrivateCA"
}
