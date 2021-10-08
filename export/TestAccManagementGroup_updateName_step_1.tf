
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211008044633118153"
  display_name = "accTestMG-211008044633118153"
}
