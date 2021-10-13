
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211013071742667405"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211013071742667405"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_cosmosdb" "test" {
  name                = "acctestlscosmosdb211013071742667405"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  account_endpoint    = "foo"
  account_key         = "bar"
  database            = "fizz"
}
