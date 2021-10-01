
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211001020702320167"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211001020702320167"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_file_storage" "test" {
  name                = "acctestlsblob211001020702320167"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  connection_string   = "DefaultEndpointsProtocol=https;AccountName=foo;AccountKey=bar"
}
