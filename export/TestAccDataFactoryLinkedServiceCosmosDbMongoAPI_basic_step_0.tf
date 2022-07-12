
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220712042158020007"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220712042158020007"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_cosmosdb_mongoapi" "test" {
  name              = "acctestlscosmosdb220712042158020007"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "mongodb://testinstance:testkey@testinstance.documents.azure.com:10255/?ssl=true"
}
