


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-postgresql-211105040317210628"
  location = "West Europe"
}


resource "azurerm_postgresql_flexible_server" "test" {
  name                   = "acctest-fs-211105040317210628"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  storage_mb             = 32768
  version                = "12"
  sku_name               = "GP_Standard_D2s_v3"
}


resource "azurerm_postgresql_flexible_server_firewall_rule" "test" {
  name             = "acctest-FSFR-211105040317210628"
  server_id        = azurerm_postgresql_flexible_server.test.id
  start_ip_address = "123.0.0.0"
  end_ip_address   = "123.0.0.0"
}
