
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230227033019594004"
  display_name = "accTestMG-230227033019594004"
}
