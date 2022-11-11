
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221111013845590744"
  display_name = "accTestMG-221111013845590744"
}
