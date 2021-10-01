
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211001224230893352"
  display_name = "accTestMG-211001224230893352"
}
