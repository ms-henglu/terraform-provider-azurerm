
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211203013707575608"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211203013707575608"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_cosmosdb_mongoapi" "test" {
  name                           = "acctestlscosmosdb211203013707575608"
  resource_group_name            = azurerm_resource_group.test.name
  data_factory_name              = azurerm_data_factory.test.name
  connection_string              = "mongodb://testinstance:testkey@testinstance.documents.azure.com:10255/?ssl=true"
  server_version_is_32_or_higher = true
}
