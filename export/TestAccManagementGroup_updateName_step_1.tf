
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220225034646122866"
  display_name = "accTestMG-220225034646122866"
}
