

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072614093169"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver231218072614093169"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_sql_server" "import" {
  name                         = azurerm_sql_server.test.name
  resource_group_name          = azurerm_sql_server.test.resource_group_name
  location                     = azurerm_sql_server.test.location
  version                      = azurerm_sql_server.test.version
  administrator_login          = azurerm_sql_server.test.administrator_login
  administrator_login_password = azurerm_sql_server.test.administrator_login_password
}
