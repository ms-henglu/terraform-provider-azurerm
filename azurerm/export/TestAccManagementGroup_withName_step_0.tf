
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220627132103673418"
  display_name = "accTestMG-220627132103673418"
}
