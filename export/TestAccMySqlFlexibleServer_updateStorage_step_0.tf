

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysql-220324163719896997"
  location = "West Europe"
}


resource "azurerm_mysql_flexible_server" "test" {
  name                         = "acctest-fs-220324163719896997"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  administrator_login          = "adminTerraform"
  administrator_password       = "QAZwsx123"
  sku_name                     = "GP_Standard_D4ds_v4"
  geo_redundant_backup_enabled = true

  storage {
    size_gb           = 20
    iops              = 360
    auto_grow_enabled = true
  }
}
