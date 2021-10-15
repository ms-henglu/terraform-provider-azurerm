
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014127476658"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "atkv211015014127476658"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211015014127476658"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_key_vault" "test" {
  name                = "acctestlskv211015014127476658"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  key_vault_id        = azurerm_key_vault.test.id
  annotations         = ["test1", "test2", "test3"]
  description         = "test description"

  parameters = {
    foo = "test1"
    bar = "test2"
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }
}
