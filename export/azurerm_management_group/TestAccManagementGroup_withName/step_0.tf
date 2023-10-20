
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-231020041422426557"
  display_name = "accTestMG-231020041422426557"
}
