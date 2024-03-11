
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-240311032526944361"
  display_name = "accTestMG-240311032526944361"
}
