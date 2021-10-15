
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211015014127463616"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211015014127463616"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_web" "test" {
  name                = "acctestlsweb211015014127463616"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name

  authentication_type = "Anonymous"
  url                 = "http://www.bing.com"
}

resource "azurerm_data_factory_dataset_http" "test" {
  name                = "acctestds211015014127463616"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  linked_service_name = azurerm_data_factory_linked_service_web.test.name

  relative_url   = "/foo/bar"
  request_body   = "OK"
  request_method = "POST"

}
