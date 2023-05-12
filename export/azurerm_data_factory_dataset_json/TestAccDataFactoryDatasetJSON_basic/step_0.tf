
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230512010553179812"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230512010553179812"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_web" "test" {
  name                = "acctestlsweb230512010553179812"
  data_factory_id     = azurerm_data_factory.test.id
  authentication_type = "Anonymous"
  url                 = "http://www.bing.com"
}

resource "azurerm_data_factory_dataset_json" "test" {
  name                = "acctestds230512010553179812"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_web.test.name

  http_server_location {
    relative_url = "/fizz/buzz/"
    path         = "foo/bar/"
    filename     = "foo.json"
  }

  encoding = "UTF-8"
}
