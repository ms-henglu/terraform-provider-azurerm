
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220722052216162582"
  display_name = "accTestMG-220722052216162582"
}
