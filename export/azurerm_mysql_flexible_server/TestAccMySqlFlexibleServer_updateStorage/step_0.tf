

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysql-221124182032719885"
  location = "West Europe"
}


resource "azurerm_mysql_flexible_server" "test" {
  name                         = "acctest-fs-221124182032719885"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  administrator_login          = "adminTerraform"
  administrator_password       = "QAZwsx123"
  sku_name                     = "GP_Standard_D4ds_v4"
  geo_redundant_backup_enabled = true
  version                      = "8.0.21"
  zone                         = "1"

  storage {
    size_gb           = 20
    iops              = 360
    auto_grow_enabled = true
  }
}
