
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230512011008177347"
  display_name = "accTestMG-230512011008177347"
}
