
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220916011346785541"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220916011346785541"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_file_storage" "test" {
  name              = "acctestlsblob220916011346785541"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "DefaultEndpointsProtocol=https;AccountName=foo;AccountKey=bar"
}
