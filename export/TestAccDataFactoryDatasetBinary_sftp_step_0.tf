
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220909034157131618"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220909034157131618"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_sftp" "test" {
  name                = "acctestlssftp220909034157131618"
  data_factory_id     = azurerm_data_factory.test.id
  authentication_type = "Basic"
  host                = "http://www.bing.com"
  port                = 22
  username            = "foo"
  password            = "bar"
}

resource "azurerm_data_factory_dataset_binary" "test" {
  name                = "acctestds220909034157131618"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_sftp.test.name

  sftp_server_location {
    path     = "/test/"
    filename = "**"
  }
}
