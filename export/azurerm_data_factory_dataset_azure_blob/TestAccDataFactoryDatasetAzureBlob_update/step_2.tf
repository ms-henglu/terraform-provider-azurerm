
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230915023301677536"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230915023301677536"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "test" {
  name              = "acctestlssql230915023301677536"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "DefaultEndpointsProtocol=https;AccountName=foo;AccountKey=bar"
}

resource "azurerm_data_factory_dataset_azure_blob" "test" {
  name                = "acctestds230915023301677536"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.test.name

  path     = "foo"
  filename = "bar.png"

  description = "test description 2"
  annotations = ["test1", "test2"]
  folder      = "testFolder"

  parameters = {
    foo  = "test1"
    bar  = "test2"
    buzz = "test3"
  }

  additional_properties = {
    foo = "test1"
  }

  schema_column {
    name        = "test1"
    type        = "Byte"
    description = "description"
  }

  schema_column {
    name        = "test2"
    type        = "Byte"
    description = "description"
  }
}
