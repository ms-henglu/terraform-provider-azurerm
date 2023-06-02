
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230602030745466801"
  display_name = "accTestMG-230602030745466801"
}
