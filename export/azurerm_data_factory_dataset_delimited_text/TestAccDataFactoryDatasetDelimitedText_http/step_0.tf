
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231020040940432058"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf231020040940432058"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_web" "test" {
  name                = "acctestlsweb231020040940432058"
  data_factory_id     = azurerm_data_factory.test.id
  authentication_type = "Anonymous"
  url                 = "https://www.bing.com"
}

resource "azurerm_data_factory_dataset_delimited_text" "test" {
  name                = "acctestds231020040940432058"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_web.test.name

  http_server_location {
    relative_url = "/fizz/buzz/"
    path         = "foo/bar/"
    filename     = "foo.txt"
  }

  column_delimiter    = ""
  row_delimiter       = ""
  encoding            = "UTF-8"
  quote_character     = ""
  escape_character    = ""
  first_row_as_header = true
  null_value          = "NULL"

}
