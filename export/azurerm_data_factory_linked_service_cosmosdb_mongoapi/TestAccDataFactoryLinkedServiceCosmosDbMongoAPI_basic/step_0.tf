
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221221204215456148"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf221221204215456148"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_cosmosdb_mongoapi" "test" {
  name              = "acctestlscosmosdb221221204215456148"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "mongodb://testinstance:testkey@testinstance.documents.azure.com:10255/?ssl=true"
}
