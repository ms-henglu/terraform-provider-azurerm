
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220909034613351041"
  display_name = "accTestMG-220909034613351041"
}
