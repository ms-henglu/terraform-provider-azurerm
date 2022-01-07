
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220107033804269952"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220107033804269952"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_cosmosdb" "test" {
  name                = "acctestlscosmosdb220107033804269952"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_id     = azurerm_data_factory.test.id
  account_endpoint    = "foo"
  account_key         = "bar"
  database            = "fizz"
}
