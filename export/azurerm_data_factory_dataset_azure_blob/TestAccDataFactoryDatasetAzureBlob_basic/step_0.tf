
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221111013423768058"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf221111013423768058"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "test" {
  name              = "acctestlssql221111013423768058"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "DefaultEndpointsProtocol=https;AccountName=foo;AccountKey=bar"
}

resource "azurerm_data_factory_dataset_azure_blob" "test" {
  name                = "acctestds221111013423768058"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.test.name

  path     = "foo"
  filename = "bar.png"
}
