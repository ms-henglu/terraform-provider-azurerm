
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240119024903018942"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240119024903018942"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "test" {
  name              = "acctestlssql240119024903018942"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "DefaultEndpointsProtocol=https;AccountName=foo;AccountKey=bar"
}

resource "azurerm_data_factory_dataset_azure_blob" "test" {
  name                = "acctestds240119024903018942"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.test.name

  path     = "foo"
  filename = "bar.png"
}
