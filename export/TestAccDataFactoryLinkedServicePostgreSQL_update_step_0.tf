
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210825044702268382"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf210825044702268382"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_postgresql" "test" {
  name                = "acctestlssql210825044702268382"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  connection_string   = "Host=example;Port=5432;Database=example;UID=example;EncryptionMethod=0;Password=example"
  annotations         = ["test1", "test2", "test3"]
  description         = "test description"

  parameters = {
    foo = "test1"
    bar = "test2"
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }
}
