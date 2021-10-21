
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211021235215495276"
  display_name = "accTestMG-211021235215495276"
}
