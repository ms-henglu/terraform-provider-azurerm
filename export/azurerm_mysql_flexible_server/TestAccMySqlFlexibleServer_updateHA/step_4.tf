

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysql-221124182032710671"
  location = "West Europe"
}


resource "azurerm_mysql_flexible_server" "test" {
  name                   = "acctest-fs-221124182032710671"
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
