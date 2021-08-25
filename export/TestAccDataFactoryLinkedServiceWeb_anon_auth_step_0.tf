
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210825044702268486"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf210825044702268486"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_web" "test" {
  name                = "acctestlsweb210825044702268486"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  authentication_type = "Anonymous"
  url                 = "http://www.bing.com"
}
