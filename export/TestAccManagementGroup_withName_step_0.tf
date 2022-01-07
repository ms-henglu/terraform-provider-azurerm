
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220107064322947056"
  display_name = "accTestMG-220107064322947056"
}
