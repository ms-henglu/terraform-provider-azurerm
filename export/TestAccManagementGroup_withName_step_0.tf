
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220812015405911971"
  display_name = "accTestMG-220812015405911971"
}
