
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211217075510190900"
  display_name = "accTestMG-211217075510190900"
}
