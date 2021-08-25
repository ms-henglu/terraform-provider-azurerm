
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210825043026370873"
  display_name = "accTestMG-210825043026370873"
}
