
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220407231157736382"
  display_name = "accTestMG-220407231157736382"
}
