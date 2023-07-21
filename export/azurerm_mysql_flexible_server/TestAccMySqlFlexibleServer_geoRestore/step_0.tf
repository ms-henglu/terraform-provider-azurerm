

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysql-230721012122498149"
  location = "West Europe"
}


resource "azurerm_mysql_flexible_server" "test" {
  name                         = "acctest-fs-230721012122498149"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  administrator_login          = "adminTerraform"
  administrator_password       = "QAZwsx123"
  geo_redundant_backup_enabled = true
  sku_name                     = "B_Standard_B1s"
}
