
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220211130846906937"
  display_name = "accTestMG-220211130846906937"
}
