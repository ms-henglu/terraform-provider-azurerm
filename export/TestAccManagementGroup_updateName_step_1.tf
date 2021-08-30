
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210830084202734301"
  display_name = "accTestMG-210830084202734301"
}
