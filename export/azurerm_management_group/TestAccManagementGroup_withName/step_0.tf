
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221111020807861837"
  display_name = "accTestMG-221111020807861837"
}
