
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220429065734347786"
  display_name = "accTestMG-220429065734347786"
}
