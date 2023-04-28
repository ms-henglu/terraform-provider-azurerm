
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428050220791517"
  location = "West Europe"
}

resource "azurerm_mysql_flexible_server" "test" {
  name                   = "acctest-fs-230428050220791517"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  sku_name               = "B_Standard_B1s"
  zone                   = "1"
}
