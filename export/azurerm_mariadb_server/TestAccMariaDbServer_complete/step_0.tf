
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034258959064"
  location = "West Europe"
}

resource "azurerm_mariadb_server" "test" {
  name                = "acctestmariadbsvr-231016034258959064"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "B_Gen5_2"
  version             = "10.3"

  administrator_login           = "acctestun"
  administrator_login_password  = "H@Sh1CoR3!"
  auto_grow_enabled             = true
  backup_retention_days         = 14
  create_mode                   = "Default"
  geo_redundant_backup_enabled  = false
  ssl_enforcement_enabled       = true
  public_network_access_enabled = true
  storage_mb                    = 51200
  tags = {
    environment = "test"
  }
}
