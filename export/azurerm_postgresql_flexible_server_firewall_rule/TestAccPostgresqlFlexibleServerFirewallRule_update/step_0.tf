


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-postgresql-240311032856776400"
  location = "West Europe"
}


resource "azurerm_postgresql_flexible_server" "test" {
  name                   = "acctest-fs-240311032856776400"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  version                = "12"
  sku_name               = "GP_Standard_D2s_v3"
  zone                   = "2"
}


resource "azurerm_postgresql_flexible_server_firewall_rule" "test" {
  name             = "acctest-FSFR-240311032856776400"
  server_id        = azurerm_postgresql_flexible_server.test.id
  start_ip_address = "122.122.0.0"
  end_ip_address   = "122.122.0.0"
}
