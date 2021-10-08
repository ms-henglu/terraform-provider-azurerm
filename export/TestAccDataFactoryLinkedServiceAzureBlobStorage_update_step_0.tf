
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211008044307081867"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211008044307081867"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "test" {
  name                = "acctestlsblob211008044307081867"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  connection_string   = "DefaultEndpointsProtocol=https;AccountName=foo2;AccountKey=bar"
  annotations         = ["test1", "test2", "test3"]
  description         = "test description"

  parameters = {
    foO = "test1"
    bar = "test2"
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }
}
