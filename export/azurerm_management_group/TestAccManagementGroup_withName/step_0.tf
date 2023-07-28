
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230728032625814170"
  display_name = "accTestMG-230728032625814170"
}
