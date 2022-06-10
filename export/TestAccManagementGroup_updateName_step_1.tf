
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220610092927397845"
  display_name = "accTestMG-220610092927397845"
}
