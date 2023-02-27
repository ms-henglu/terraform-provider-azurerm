
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230227033019597377"
  display_name = "accTestMG-230227033019597377"
}
