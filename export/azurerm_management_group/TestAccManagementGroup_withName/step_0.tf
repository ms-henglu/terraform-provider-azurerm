
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221028172430490417"
  display_name = "accTestMG-221028172430490417"
}
