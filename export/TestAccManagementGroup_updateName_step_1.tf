
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220527024441768864"
  display_name = "accTestMG-220527024441768864"
}
