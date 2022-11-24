
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221124181942395542"
  display_name = "accTestMG-221124181942395542"
}
