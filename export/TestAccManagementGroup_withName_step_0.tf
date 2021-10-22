
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211022002154877480"
  display_name = "accTestMG-211022002154877480"
}
