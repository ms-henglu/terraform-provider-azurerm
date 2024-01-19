
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240119024903046258"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240119024903046258"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_sql_database" "test" {
  name              = "acctestlssql240119024903046258"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "data source=serverhostname;initial catalog=master;user id=testUser;Password=test;integrated security=False;encrypt=True;connection timeout=30"
}
