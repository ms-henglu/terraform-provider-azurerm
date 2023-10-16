
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231016033759700528"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf231016033759700528"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_sql_server" "test" {
  name              = "acctestlssql231016033759700528"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "Integrated Security=False;Data Source=test;Initial Catalog=test;User ID=test;Password=test"
  annotations       = ["test1", "test2", "test3"]
  description       = "test description"

  parameters = {
    foo = "test1"
    bar = "test2"
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }
}
