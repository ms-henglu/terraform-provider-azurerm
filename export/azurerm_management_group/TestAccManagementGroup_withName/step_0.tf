
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230929065229083870"
  display_name = "accTestMG-230929065229083870"
}
