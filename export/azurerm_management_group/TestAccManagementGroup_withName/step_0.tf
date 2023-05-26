
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230526085431596401"
  display_name = "accTestMG-230526085431596401"
}
