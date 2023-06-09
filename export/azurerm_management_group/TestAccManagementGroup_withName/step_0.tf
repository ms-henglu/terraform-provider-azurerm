
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230609091611517670"
  display_name = "accTestMG-230609091611517670"
}
