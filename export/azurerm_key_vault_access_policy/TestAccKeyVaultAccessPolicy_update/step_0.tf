
provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613072035460129"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestkv-t8ii1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}


resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.test.id

  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
    "Set",
  ]

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
}
