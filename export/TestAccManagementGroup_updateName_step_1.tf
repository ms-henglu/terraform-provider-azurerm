
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211112020858363878"
  display_name = "accTestMG-211112020858363878"
}
