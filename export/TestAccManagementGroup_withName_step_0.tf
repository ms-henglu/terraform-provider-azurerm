
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211210035030858221"
  display_name = "accTestMG-211210035030858221"
}
