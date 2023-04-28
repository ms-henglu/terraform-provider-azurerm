
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230428050103101851"
  display_name = "accTestMG-230428050103101851"
}
