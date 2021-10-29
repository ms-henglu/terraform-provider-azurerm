
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211029015454604279"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211029015454604279"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_web" "test" {
  name                = "acctestlsweb211029015454604279"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  authentication_type = "Basic"
  url                 = "http://www.bing.com"
  username            = "foo"
  password            = "bar"
}
