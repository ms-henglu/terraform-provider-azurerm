
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230316221417289559"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230316221417289559"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_odbc" "test" {
  name              = "acctestlsodbc230316221417289559"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "Driver={SQL Server};Server=test;Database=test;Uid=test;Pwd=test;"
}
