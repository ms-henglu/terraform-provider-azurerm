
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220729032952926846"
  display_name = "accTestMG-220729032952926846"
}
