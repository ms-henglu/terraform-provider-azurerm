
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230929064753246706"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230929064753246706"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_web" "test" {
  name                = "acctestlsweb230929064753246706"
  data_factory_id     = azurerm_data_factory.test.id
  authentication_type = "Anonymous"
  url                 = "http://www.bing.com"
}

resource "azurerm_data_factory_dataset_parquet" "test" {
  name                = "acctestds230929064753246706"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_web.test.name

  http_server_location {
    relative_url = "/fizz/buzz/"
    path         = "foo/bar/"
    filename     = "foo.txt"
  }

  description = "test description"
  annotations = ["test1", "test2", "test3"]

  folder = "testFolder"

  compression_codec = "gzip"

  parameters = {
    foo = "test1"
    bar = "test2"
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }

  schema_column {
    name        = "test1"
    type        = "Byte"
    description = "description"
  }
}
