
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-231020041422429298"
  display_name = "accTestMG-231020041422429298"
}
