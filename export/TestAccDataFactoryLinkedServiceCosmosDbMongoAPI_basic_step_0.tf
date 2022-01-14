
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220114014123262762"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220114014123262762"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_cosmosdb_mongoapi" "test" {
  name                = "acctestlscosmosdb220114014123262762"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_id     = azurerm_data_factory.test.id
  connection_string   = "mongodb://testinstance:testkey@testinstance.documents.azure.com:10255/?ssl=true"
}
