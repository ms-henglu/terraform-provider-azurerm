
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230721011523156380"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230721011523156380"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory_linked_service_azure_sql_database" "test" {
  name                 = "acctestlssql230721011523156380"
  data_factory_id      = azurerm_data_factory.test.id
  connection_string    = "data source=serverhostname;initial catalog=master;user id=testUser;Password=test;integrated security=False;encrypt=True;connection timeout=30"
  use_managed_identity = true
}
