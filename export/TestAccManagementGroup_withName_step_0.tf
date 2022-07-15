
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220715014725507807"
  display_name = "accTestMG-220715014725507807"
}
