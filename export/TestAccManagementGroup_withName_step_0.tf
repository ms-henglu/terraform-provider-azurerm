
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220128052746325672"
  display_name = "accTestMG-220128052746325672"
}
