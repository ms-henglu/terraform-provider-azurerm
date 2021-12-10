
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211210034558585599"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211210034558585599"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_cosmosdb_mongoapi" "test" {
  name                           = "acctestlscosmosdb211210034558585599"
  resource_group_name            = azurerm_resource_group.test.name
  data_factory_id                = azurerm_data_factory.test.id
  connection_string              = "mongodb://testinstance:testkey@testinstance.documents.azure.com:10255/?ssl=true"
  server_version_is_32_or_higher = true
}
