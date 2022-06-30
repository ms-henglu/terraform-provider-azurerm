
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220630211042674236"
  display_name = "accTestMG-220630211042674236"
}
