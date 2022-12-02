
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221202040017217094"
  display_name = "accTestMG-221202040017217094"
}
