
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "readscaletestRG-240112035217835418"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "readscaletestsqlserver240112035217835418"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_database" "test" {
  name                = "readscaletestdb240112035217835418"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_sql_server.test.name
  location            = azurerm_resource_group.test.location
  edition             = "Premium"
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  max_size_bytes      = "1073741824"
  read_scale          = true
}
