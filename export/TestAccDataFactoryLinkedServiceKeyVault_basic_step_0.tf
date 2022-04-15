
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415030416686719"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "atkv220415030416686719"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220415030416686719"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_key_vault" "test" {
  name            = "acctestlskv220415030416686719"
  data_factory_id = azurerm_data_factory.test.id
  key_vault_id    = azurerm_key_vault.test.id
}
