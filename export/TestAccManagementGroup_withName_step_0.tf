
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210830084202733620"
  display_name = "accTestMG-210830084202733620"
}
