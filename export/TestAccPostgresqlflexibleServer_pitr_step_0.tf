

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-postgresql-211015014634878297"
  location = "West Europe"
}


resource "azurerm_postgresql_flexible_server" "test" {
  name                   = "acctest-fs-211015014634878297"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  storage_mb             = 32768
  version                = "12"
  sku_name               = "GP_Standard_D2s_v3"
}
