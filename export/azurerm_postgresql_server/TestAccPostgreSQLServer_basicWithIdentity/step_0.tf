
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-221222035141011926"
  location = "West Europe"
}

resource "azurerm_postgresql_server" "test" {
  name                = "acctest-psql-server-221222035141011926"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_1"
  version    = "11"
  storage_mb = 51200

  ssl_enforcement_enabled = true

  identity {
    type = "SystemAssigned"
  }
}
