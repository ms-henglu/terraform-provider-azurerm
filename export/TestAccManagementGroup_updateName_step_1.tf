
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220415030750615815"
  display_name = "accTestMG-220415030750615815"
}
