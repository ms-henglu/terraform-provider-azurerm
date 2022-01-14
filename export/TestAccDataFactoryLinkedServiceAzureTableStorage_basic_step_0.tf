
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220114064035708553"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220114064035708553"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_table_storage" "test" {
  name                = "acctestlsblob220114064035708553"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_id     = azurerm_data_factory.test.id
  connection_string   = "DefaultEndpointsProtocol=https;AccountName=foo;AccountKey=bar"
}
