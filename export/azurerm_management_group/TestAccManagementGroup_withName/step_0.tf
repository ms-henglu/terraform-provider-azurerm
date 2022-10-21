
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221021031442258697"
  display_name = "accTestMG-221021031442258697"
}
