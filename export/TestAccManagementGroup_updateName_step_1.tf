
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220909034613351556"
  display_name = "accTestMG-220909034613351556"
}
