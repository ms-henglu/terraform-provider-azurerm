
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210910021617117578"
  display_name = "accTestMG-210910021617117578"
}
