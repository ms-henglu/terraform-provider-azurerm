
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220429065734340399"
  display_name = "accTestMG-220429065734340399"
}
