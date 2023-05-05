



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-postgresql-230505051038661798"
  location = "West Europe"
}


resource "azurerm_postgresql_flexible_server" "test" {
  name                   = "acctest-fs-230505051038661798"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  storage_mb             = 32768
  version                = "12"
  sku_name               = "GP_Standard_D2s_v3"
  zone                   = "2"
}


resource "azurerm_postgresql_flexible_server_firewall_rule" "test" {
  name             = "acctest-FSFR-230505051038661798"
  server_id        = azurerm_postgresql_flexible_server.test.id
  start_ip_address = "122.122.0.0"
  end_ip_address   = "122.122.0.0"
}


resource "azurerm_postgresql_flexible_server_firewall_rule" "import" {
  name             = azurerm_postgresql_flexible_server_firewall_rule.test.name
  server_id        = azurerm_postgresql_flexible_server_firewall_rule.test.server_id
  start_ip_address = azurerm_postgresql_flexible_server_firewall_rule.test.start_ip_address
  end_ip_address   = azurerm_postgresql_flexible_server_firewall_rule.test.end_ip_address
}
