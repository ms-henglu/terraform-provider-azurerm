
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230630033516408426"
  display_name = "accTestMG-230630033516408426"
}
