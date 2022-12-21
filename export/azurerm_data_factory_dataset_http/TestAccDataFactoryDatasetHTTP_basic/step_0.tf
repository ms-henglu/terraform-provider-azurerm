
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221221204215434620"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf221221204215434620"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_web" "test" {
  name            = "acctestlsweb221221204215434620"
  data_factory_id = azurerm_data_factory.test.id

  authentication_type = "Anonymous"
  url                 = "http://www.bing.com"
}

resource "azurerm_data_factory_dataset_http" "test" {
  name                = "acctestds221221204215434620"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_web.test.name

  relative_url   = "/foo/bar"
  request_body   = "OK"
  request_method = "POST"

}
