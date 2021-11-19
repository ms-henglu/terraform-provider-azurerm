
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211119050737595097"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211119050737595097"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_cosmosdb_mongoapi" "test" {
  name                           = "acctestlscosmosdb211119050737595097"
  resource_group_name            = azurerm_resource_group.test.name
  data_factory_name              = azurerm_data_factory.test.name
  connection_string              = "mongodb://testinstance:testkey@testinstance.documents.azure.com:10255/?ssl=true"
  server_version_is_32_or_higher = true
}
