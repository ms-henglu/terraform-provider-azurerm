
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220623223623741344"
  display_name = "accTestMG-220623223623741344"
}
