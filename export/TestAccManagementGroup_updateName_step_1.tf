
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220520040908050254"
  display_name = "accTestMG-220520040908050254"
}
