
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221111020807868053"
  display_name = "accTestMG-221111020807868053"
}
