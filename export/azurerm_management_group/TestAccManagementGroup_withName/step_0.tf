
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221221204534515737"
  display_name = "accTestMG-221221204534515737"
}
