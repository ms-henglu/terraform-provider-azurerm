
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211015014127471488"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211015014127471488"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_cosmosdb_mongoapi" "test" {
  name                = "acctestlscosmosdb211015014127471488"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  connection_string   = "mongodb://testinstance:testkey@testinstance.documents.azure.com:10255/?ssl=true"
}
