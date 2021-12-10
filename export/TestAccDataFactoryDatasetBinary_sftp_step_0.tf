
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211210024512743585"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211210024512743585"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_sftp" "test" {
  name                = "acctestlssftp211210024512743585"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  authentication_type = "Basic"
  host                = "http://www.bing.com"
  port                = 22
  username            = "foo"
  password            = "bar"
}

resource "azurerm_data_factory_dataset_binary" "test" {
  name                = "acctestds211210024512743585"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  linked_service_name = azurerm_data_factory_linked_service_sftp.test.name

  sftp_server_location {
    path     = "/test/"
    filename = "**"
  }
}
