
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230825024423949306"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230825024423949306"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory_linked_service_azure_sql_database" "test" {
  name                 = "acctestlssql230825024423949306"
  data_factory_id      = azurerm_data_factory.test.id
  connection_string    = "data source=serverhostname;initial catalog=master;user id=testUser;Password=test;integrated security=False;encrypt=True;connection timeout=30"
  use_managed_identity = true
}
