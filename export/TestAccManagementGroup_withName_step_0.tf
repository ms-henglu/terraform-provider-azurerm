
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211126031408643926"
  display_name = "accTestMG-211126031408643926"
}
