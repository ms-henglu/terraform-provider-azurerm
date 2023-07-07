
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230707003750946577"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230707003750946577"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_sftp" "test" {
  name                = "acctestlssftp230707003750946577"
  data_factory_id     = azurerm_data_factory.test.id
  authentication_type = "Basic"
  host                = "http://www.bing.com"
  port                = 22
  username            = "foo"
  password            = "bar"
}

resource "azurerm_data_factory_dataset_binary" "test" {
  name                = "acctestds230707003750946577"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_sftp.test.name

  sftp_server_location {
    path     = "/test/"
    filename = "**"
  }
}
