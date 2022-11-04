
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221104005634146702"
  display_name = "accTestMG-221104005634146702"
}
