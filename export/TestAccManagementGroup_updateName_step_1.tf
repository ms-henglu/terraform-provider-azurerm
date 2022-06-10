
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220610022815558727"
  display_name = "accTestMG-220610022815558727"
}
