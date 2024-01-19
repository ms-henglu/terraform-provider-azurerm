
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240119024903047287"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240119024903047287"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_table_storage" "test" {
  name              = "acctestlsblob240119024903047287"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "DefaultEndpointsProtocol=https;AccountName=foo;AccountKey=bar"
}
