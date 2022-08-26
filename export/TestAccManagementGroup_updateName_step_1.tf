
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220826002957388806"
  display_name = "accTestMG-220826002957388806"
}
