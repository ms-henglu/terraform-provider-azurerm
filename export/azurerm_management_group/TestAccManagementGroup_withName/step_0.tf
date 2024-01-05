
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-240105061112129418"
  display_name = "accTestMG-240105061112129418"
}
