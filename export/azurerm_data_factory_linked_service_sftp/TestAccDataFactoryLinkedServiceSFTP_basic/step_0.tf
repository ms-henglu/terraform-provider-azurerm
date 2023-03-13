
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230313021052288890"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230313021052288890"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_sftp" "test" {
  name                = "acctestlsweb230313021052288890"
  data_factory_id     = azurerm_data_factory.test.id
  authentication_type = "Basic"
  host                = "http://www.bing.com"
  port                = 22
  username            = "foo"
  password            = "bar"
}
