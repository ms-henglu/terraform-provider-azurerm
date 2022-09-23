
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220923012048608500"
  display_name = "accTestMG-220923012048608500"
}
