
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210906022448466685"
  display_name = "accTestMG-210906022448466685"
}
