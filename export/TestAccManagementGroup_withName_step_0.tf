
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220326010819281145"
  display_name = "accTestMG-220326010819281145"
}
