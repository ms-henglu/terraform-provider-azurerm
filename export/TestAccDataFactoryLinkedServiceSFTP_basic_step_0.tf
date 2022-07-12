
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220712042158028335"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220712042158028335"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_sftp" "test" {
  name                = "acctestlsweb220712042158028335"
  data_factory_id     = azurerm_data_factory.test.id
  authentication_type = "Basic"
  host                = "http://www.bing.com"
  port                = 22
  username            = "foo"
  password            = "bar"
}
