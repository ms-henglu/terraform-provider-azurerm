
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221124181538946642"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf221124181538946642"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_odbc" "test" {
  name              = "acctestlsodbc221124181538946642"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "Driver={SQL Server};Server=test;Database=test;Uid=test;Pwd=test;"
  basic_authentication {
    username = "onrylmz"
    password = "Ch4ngeM3!"
  }
}
