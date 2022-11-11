
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221111013423827923"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf221111013423827923"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_web" "test" {
  name                = "acctestlsweb221111013423827923"
  data_factory_id     = azurerm_data_factory.test.id
  authentication_type = "Anonymous"
  url                 = "http://www.bing.com"
}
