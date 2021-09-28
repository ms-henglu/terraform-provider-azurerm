
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210928055638755805"
  display_name = "accTestMG-210928055638755805"
}
