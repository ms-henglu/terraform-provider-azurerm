
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220527024441761162"
  display_name = "accTestMG-220527024441761162"
}
