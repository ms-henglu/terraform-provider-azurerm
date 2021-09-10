
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210910021617113913"
  display_name = "accTestMG-210910021617113913"
}
