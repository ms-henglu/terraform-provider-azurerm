
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221202040017216185"
  display_name = "accTestMG-221202040017216185"
}
