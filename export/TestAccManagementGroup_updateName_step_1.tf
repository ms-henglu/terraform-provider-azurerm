
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220729032952925274"
  display_name = "accTestMG-220729032952925274"
}
