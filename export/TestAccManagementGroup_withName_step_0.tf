
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220107034142802919"
  display_name = "accTestMG-220107034142802919"
}
