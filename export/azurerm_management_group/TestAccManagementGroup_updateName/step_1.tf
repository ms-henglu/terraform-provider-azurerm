
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-240105064139675838"
  display_name = "accTestMG-240105064139675838"
}
