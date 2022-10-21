
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221021034324051715"
  display_name = "accTestMG-221021034324051715"
}
