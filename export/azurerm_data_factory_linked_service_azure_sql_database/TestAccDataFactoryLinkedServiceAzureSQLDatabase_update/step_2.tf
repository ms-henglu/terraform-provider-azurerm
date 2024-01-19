
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240119024903041127"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240119024903041127"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_sql_database" "test" {
  name              = "acctestlssql240119024903041127"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "data source=serverhostname;initial catalog=master;user id=testUser;Password=test;integrated security=False;encrypt=True;connection timeout=30;"
  annotations       = ["test1", "test2"]
  description       = "test description 2"

  parameters = {
    foo  = "test1"
    bar  = "test2"
    buzz = "test3"
  }

  additional_properties = {
    foo = "test1"
  }
}
