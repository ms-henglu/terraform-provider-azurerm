
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210906022448468515"
  display_name = "accTestMG-210906022448468515"
}
