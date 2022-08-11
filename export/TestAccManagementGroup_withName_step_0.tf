
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220811053528924409"
  display_name = "accTestMG-220811053528924409"
}
