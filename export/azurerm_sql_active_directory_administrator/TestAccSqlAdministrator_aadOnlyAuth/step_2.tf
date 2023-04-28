
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428050616777329"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver230428050616777329"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_active_directory_administrator" "test" {
  server_name                 = azurerm_sql_server.test.name
  resource_group_name         = azurerm_resource_group.test.name
  login                       = "sqladmin"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  object_id                   = data.azurerm_client_config.current.client_id
  azuread_authentication_only = false
}
