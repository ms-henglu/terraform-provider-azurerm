
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211105035757867059"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211105035757867059"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_web" "test" {
  name                = "acctestlsweb211105035757867059"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  authentication_type = "Anonymous"
  url                 = "http://www.bing.com"
}

resource "azurerm_data_factory_dataset_json" "test" {
  name                = "acctestds211105035757867059"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  linked_service_name = azurerm_data_factory_linked_service_web.test.name

  http_server_location {
    relative_url             = "/fizz/buzz/"
    path                     = "@concat('foo/bar/',formatDateTime(convertTimeZone(utcnow(),'UTC','W. Europe Standard Time'),'yyyy-MM-dd'))"
    dynamic_path_enabled     = true
    filename                 = "@concat('foo', '.json')"
    dynamic_filename_enabled = true
  }

  encoding = "UTF-8"

  description = "test description"
  annotations = ["test1", "test2", "test3"]
  folder      = "testFolder"

  parameters = {
    foo = "test1"
    Bar = "Test2"
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
