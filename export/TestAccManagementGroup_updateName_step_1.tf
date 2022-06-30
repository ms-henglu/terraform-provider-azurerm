
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220630211042670048"
  display_name = "accTestMG-220630211042670048"
}
