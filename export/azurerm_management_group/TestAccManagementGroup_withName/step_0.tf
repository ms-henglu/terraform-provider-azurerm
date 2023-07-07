
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230707010627785483"
  display_name = "accTestMG-230707010627785483"
}
