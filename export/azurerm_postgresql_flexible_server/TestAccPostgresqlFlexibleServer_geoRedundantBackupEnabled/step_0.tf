

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-postgresql-230922061732450195"
  location = "West Europe"
}


resource "azurerm_postgresql_flexible_server" "test" {
  name                         = "acctest-fs-230922061732450195"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  administrator_login          = "adminTerraform"
  administrator_password       = "QAZwsx123"
  storage_mb                   = 32768
  version                      = "12"
  sku_name                     = "GP_Standard_D2s_v3"
  zone                         = "2"
  backup_retention_days        = 7
  geo_redundant_backup_enabled = true
}
