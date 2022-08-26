
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220826010243355926"
  display_name = "accTestMG-220826010243355926"
}
