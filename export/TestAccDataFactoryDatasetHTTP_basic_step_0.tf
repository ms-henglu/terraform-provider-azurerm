
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220627131045416826"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220627131045416826"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_web" "test" {
  name            = "acctestlsweb220627131045416826"
  data_factory_id = azurerm_data_factory.test.id

  authentication_type = "Anonymous"
  url                 = "http://www.bing.com"
}

resource "azurerm_data_factory_dataset_http" "test" {
  name                = "acctestds220627131045416826"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_web.test.name

  relative_url   = "/foo/bar"
  request_body   = "OK"
  request_method = "POST"

}
