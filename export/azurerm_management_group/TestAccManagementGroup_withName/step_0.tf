
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230120052323103399"
  display_name = "accTestMG-230120052323103399"
}
