
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211001224230896442"
  display_name = "accTestMG-211001224230896442"
}
