
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211015014127486533"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211015014127486533"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_sftp" "test" {
  name                = "acctestlsweb211015014127486533"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  authentication_type = "Basic"
  host                = "http://www.bing.com"
  port                = 22
  username            = "foo"
  password            = "bar"
  annotations         = ["test1", "test2", "test3"]
  description         = "test description"

  parameters = {
    foo = "test1"
    bar = "test2"
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }
}
