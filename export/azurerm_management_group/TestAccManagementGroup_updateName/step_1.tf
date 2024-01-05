
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-240105061112124837"
  display_name = "accTestMG-240105061112124837"
}
