
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220630223910600812"
  display_name = "accTestMG-220630223910600812"
}
