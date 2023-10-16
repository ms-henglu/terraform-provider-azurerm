

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysql-231016034356092798"
  location = "West Europe"
}


resource "azurerm_mysql_flexible_server" "test" {
  name                         = "acctest-fs-231016034356092798"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  administrator_login          = "adminTerraform"
  administrator_password       = "QAZwsx123"
  sku_name                     = "GP_Standard_D4ds_v4"
  geo_redundant_backup_enabled = true
  version                      = "8.0.21"
  zone                         = "1"

  storage {
    size_gb            = 34
    auto_grow_enabled  = false
    io_scaling_enabled = true
  }
}
