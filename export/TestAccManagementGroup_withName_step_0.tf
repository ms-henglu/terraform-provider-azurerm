
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220124122333520661"
  display_name = "accTestMG-220124122333520661"
}
