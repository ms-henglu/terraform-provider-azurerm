


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-postgresql-231016034526734518"
  location = "West Europe"
}


resource "azurerm_postgresql_flexible_server" "test" {
  name                   = "acctest-fs-231016034526734518"
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
  name             = "acctest-FSFR-231016034526734518"
  server_id        = azurerm_postgresql_flexible_server.test.id
  start_ip_address = "122.122.0.0"
  end_ip_address   = "122.122.0.0"
}
