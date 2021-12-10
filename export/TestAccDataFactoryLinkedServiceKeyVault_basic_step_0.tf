
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024512753996"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "atkv211210024512753996"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211210024512753996"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_key_vault" "test" {
  name                = "acctestlskv211210024512753996"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_id     = azurerm_data_factory.test.id
  key_vault_id        = azurerm_key_vault.test.id
}
