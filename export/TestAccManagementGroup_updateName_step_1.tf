
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220218070959697430"
  display_name = "accTestMG-220218070959697430"
}
