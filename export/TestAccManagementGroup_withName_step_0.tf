
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211008044633116779"
  display_name = "accTestMG-211008044633116779"
}
