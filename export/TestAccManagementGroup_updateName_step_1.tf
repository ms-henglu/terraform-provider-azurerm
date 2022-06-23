
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220623233951768168"
  display_name = "accTestMG-220623233951768168"
}
