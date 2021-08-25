
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210825031841296610"
  display_name = "accTestMG-210825031841296610"
}
