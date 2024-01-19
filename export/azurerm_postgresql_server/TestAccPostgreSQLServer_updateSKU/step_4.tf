
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-240119025622778130"
  location = "West Europe"
}

resource "azurerm_postgresql_server" "test" {
  name                = "acctest-psql-server-240119025622778130"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "MO_Gen5_16"
  storage_mb = 51200
  version    = "10.0"

  ssl_enforcement_enabled = true
}
