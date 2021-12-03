
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211203014055711845"
  display_name = "accTestMG-211203014055711845"
}
