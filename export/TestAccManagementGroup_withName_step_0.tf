
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220623233951762440"
  display_name = "accTestMG-220623233951762440"
}
