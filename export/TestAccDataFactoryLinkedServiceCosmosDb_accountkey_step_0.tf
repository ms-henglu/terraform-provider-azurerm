
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211217075141440430"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211217075141440430"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_cosmosdb" "test" {
  name                = "acctestlscosmosdb211217075141440430"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_id     = azurerm_data_factory.test.id
  account_endpoint    = "foo"
  account_key         = "bar"
  database            = "fizz"
}
