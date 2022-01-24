
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220124122333524761"
  display_name = "accTestMG-220124122333524761"
}
