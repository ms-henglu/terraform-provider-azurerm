
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220826010243353005"
  display_name = "accTestMG-220826010243353005"
}
