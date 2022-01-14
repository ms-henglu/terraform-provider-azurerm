
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220114064345399330"
  display_name = "accTestMG-220114064345399330"
}
