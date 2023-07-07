
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230707003750970249"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230707003750970249"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_odbc" "test" {
  name              = "acctestlsodbc230707003750970249"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "Driver={SQL Server};Server=test;Database=test;Uid=test;Pwd=test;"
  annotations       = ["test1", "test2"]
  description       = "Test Description 2"

  parameters = {
    foo  = "Test1"
    bar  = "Test2"
    buzz = "Test3"
  }

  additional_properties = {
    foo = "Test1"
  }
}
