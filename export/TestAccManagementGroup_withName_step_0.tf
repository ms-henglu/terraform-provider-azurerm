
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210825041022286018"
  display_name = "accTestMG-210825041022286018"
}
