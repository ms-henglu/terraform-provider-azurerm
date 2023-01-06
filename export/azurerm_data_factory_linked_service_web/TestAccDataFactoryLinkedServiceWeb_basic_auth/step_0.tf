
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230106031348179807"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230106031348179807"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_web" "test" {
  name                = "acctestlsweb230106031348179807"
  data_factory_id     = azurerm_data_factory.test.id
  authentication_type = "Basic"
  url                 = "http://www.bing.com"
  username            = "foo"
  password            = "bar"
}
