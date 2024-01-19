
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025452511824"
  location = "West Europe"
}

resource "azurerm_mysql_server" "test" {
  name                = "acctestmysqlsvr-240119025452511824"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "MO_Gen5_16"
  version             = "5.7"

  storage_mb                   = 16777216
  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"
  ssl_enforcement_enabled      = true
}
