
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220211130846906104"
  display_name = "accTestMG-220211130846906104"
}
