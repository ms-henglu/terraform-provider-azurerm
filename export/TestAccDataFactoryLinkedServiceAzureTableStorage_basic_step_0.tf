
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211008044307084932"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211008044307084932"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_table_storage" "test" {
  name                = "acctestlsblob211008044307084932"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  connection_string   = "DefaultEndpointsProtocol=https;AccountName=foo;AccountKey=bar"
}
