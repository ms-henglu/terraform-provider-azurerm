
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220610092927395844"
  display_name = "accTestMG-220610092927395844"
}
