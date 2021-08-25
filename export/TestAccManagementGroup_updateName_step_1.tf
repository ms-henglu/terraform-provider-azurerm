
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210825043026377240"
  display_name = "accTestMG-210825043026377240"
}
