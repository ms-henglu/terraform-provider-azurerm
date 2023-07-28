
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230728032625812289"
  display_name = "accTestMG-230728032625812289"
}
