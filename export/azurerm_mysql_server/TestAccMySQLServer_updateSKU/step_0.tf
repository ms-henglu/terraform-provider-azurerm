
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230324052455228595"
  location = "West Europe"
}

resource "azurerm_mysql_server" "test" {
  name                = "acctestmysqlsvr-230324052455228595"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "GP_Gen5_2"
  version             = "5.7"

  storage_mb                   = 16777216
  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"
  ssl_enforcement_enabled      = true
}
