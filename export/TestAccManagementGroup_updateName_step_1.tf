
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220429075632977354"
  display_name = "accTestMG-220429075632977354"
}
