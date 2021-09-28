
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210928055341225972"
  location = "West Europe"
}
resource "azurerm_data_factory" "test" {
  name                = "acctestdf210928055341225972"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}
data "azurerm_client_config" "current" {
}
resource "azurerm_data_factory_linked_service_azure_sql_database" "test" {
  name                 = "acctestlssql210928055341225972"
  resource_group_name  = azurerm_resource_group.test.name
  data_factory_name    = azurerm_data_factory.test.name
  connection_string    = "data source=serverhostname;initial catalog=master;user id=testUser;Password=test;integrated security=False;encrypt=True;connection timeout=30"
  use_managed_identity = true
}
