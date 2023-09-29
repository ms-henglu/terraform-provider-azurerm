
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230929064753279411"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230929064753279411"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_cosmosdb_mongoapi" "test" {
  name              = "acctestlscosmosdb230929064753279411"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "mongodb://testinstance:testkey@testinstance.documents.azure.com:10255/?ssl=true"
}
