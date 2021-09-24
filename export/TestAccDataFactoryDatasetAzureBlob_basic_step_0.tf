
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210924010904953082"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf210924010904953082"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "test" {
  name                = "acctestlssql210924010904953082"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  connection_string   = "DefaultEndpointsProtocol=https;AccountName=foo;AccountKey=bar"
}

resource "azurerm_data_factory_dataset_azure_blob" "test" {
  name                = "acctestds210924010904953082"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.test.name

  path     = "foo"
  filename = "bar.png"
}
