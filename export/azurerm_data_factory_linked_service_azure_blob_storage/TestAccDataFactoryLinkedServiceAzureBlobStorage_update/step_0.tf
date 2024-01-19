
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240119024903033548"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240119024903033548"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "test" {
  name              = "acctestlsblob240119024903033548"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "DefaultEndpointsProtocol=https;AccountName=foo2;AccountKey=bar"
  annotations       = ["test1", "test2", "test3"]
  description       = "test description"

  parameters = {
    foO = "test1"
    bar = "test2"
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }
}
