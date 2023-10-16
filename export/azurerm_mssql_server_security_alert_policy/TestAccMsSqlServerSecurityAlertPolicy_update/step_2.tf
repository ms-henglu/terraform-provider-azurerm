

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-231016034338834160"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver231016034338834160"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_storage_account" "test" {
  name                     = "accsa231016034338834160"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}


resource "azurerm_mssql_server_security_alert_policy" "test" {
  resource_group_name  = azurerm_resource_group.test.name
  server_name          = azurerm_mssql_server.test.name
  state                = "Enabled"
  email_account_admins = true
  retention_days       = 30
}
