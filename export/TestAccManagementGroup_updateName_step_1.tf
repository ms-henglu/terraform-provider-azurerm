
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211013072105762177"
  display_name = "accTestMG-211013072105762177"
}
