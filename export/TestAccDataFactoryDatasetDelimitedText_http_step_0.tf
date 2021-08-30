
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210830083901612285"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf210830083901612285"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_web" "test" {
  name                = "acctestlsweb210830083901612285"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  authentication_type = "Anonymous"
  url                 = "https://www.bing.com"
}

resource "azurerm_data_factory_dataset_delimited_text" "test" {
  name                = "acctestds210830083901612285"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
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
