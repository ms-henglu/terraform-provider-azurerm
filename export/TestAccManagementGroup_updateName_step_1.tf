
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220818235356137845"
  display_name = "accTestMG-220818235356137845"
}
