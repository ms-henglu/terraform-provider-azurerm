
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220415030750617789"
  display_name = "accTestMG-220415030750617789"
}
