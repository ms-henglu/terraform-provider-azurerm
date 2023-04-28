
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230428050103101387"
  display_name = "accTestMG-230428050103101387"
}
