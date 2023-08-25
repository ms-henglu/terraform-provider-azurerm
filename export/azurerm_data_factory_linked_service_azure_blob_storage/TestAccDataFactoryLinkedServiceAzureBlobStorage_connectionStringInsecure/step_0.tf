
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230825024423941800"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230825024423941800"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "test" {
  name                       = "acctestlsblob230825024423941800"
  data_factory_id            = azurerm_data_factory.test.id
  connection_string_insecure = "DefaultEndpointsProtocol=https;AccountName=foo;AccountKey=bar"
}
