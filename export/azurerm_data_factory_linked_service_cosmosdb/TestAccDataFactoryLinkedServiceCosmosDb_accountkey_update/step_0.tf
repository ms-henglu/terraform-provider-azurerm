
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230526084957303518"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230526084957303518"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_cosmosdb" "test" {
  name             = "acctestlscosmosdb230526084957303518"
  data_factory_id  = azurerm_data_factory.test.id
  account_endpoint = "foo"
  account_key      = "bar"
  database         = "fizz"
}
