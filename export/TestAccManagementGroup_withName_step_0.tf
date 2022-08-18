
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220818235356121078"
  display_name = "accTestMG-220818235356121078"
}
