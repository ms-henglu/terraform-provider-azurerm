
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230804030252034838"
  display_name = "accTestMG-230804030252034838"
}
