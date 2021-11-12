
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211112020507579110"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211112020507579110"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_cosmosdb" "test" {
  name                = "acctestlscosmosdb211112020507579110"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  account_endpoint    = "foo"
  account_key         = "bar"
  database            = "buzz"
}
