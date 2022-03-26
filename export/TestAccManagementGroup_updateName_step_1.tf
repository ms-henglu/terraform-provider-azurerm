
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220326010819284107"
  display_name = "accTestMG-220326010819284107"
}
