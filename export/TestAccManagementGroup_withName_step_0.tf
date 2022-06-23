
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220623223623746926"
  display_name = "accTestMG-220623223623746926"
}
