
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-231016034526743123"
  location = "West Europe"
}

resource "azurerm_postgresql_server" "test" {
  name                = "acctest-psql-server-231016034526743123"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "GP_Gen5_2"
  version    = "9.6"
  storage_mb = 51200

  ssl_enforcement_enabled = true
}
