
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210928055341228691"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf210928055341228691"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "test" {
  name                = "acctestlsblob210928055341228691"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name

  connection_string = "DefaultEndpointsProtocol=https;AccountName=foo3;AccountKey=bar"
  annotations       = ["Test1", "Test2"]
  description       = "test description 2"

  parameters = {
    foo  = "Test1"
    bar  = "test2"
    buzz = "test3"
  }

  additional_properties = {
    foo = "test1"
  }
}
