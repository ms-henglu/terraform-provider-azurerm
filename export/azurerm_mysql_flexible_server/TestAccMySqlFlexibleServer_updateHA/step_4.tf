

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysql-230609091720277066"
  location = "West Europe"
}


resource "azurerm_mysql_flexible_server" "test" {
  name                   = "acctest-fs-230609091720277066"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"

  high_availability {
    mode = "SameZone"
  }

  sku_name = "GP_Standard_D2ds_v4"
  zone     = "1"

  lifecycle {
    ignore_changes = [
      high_availability.0.standby_availability_zone
    ]
  }
}
