
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230602030745466350"
  display_name = "accTestMG-230602030745466350"
}
