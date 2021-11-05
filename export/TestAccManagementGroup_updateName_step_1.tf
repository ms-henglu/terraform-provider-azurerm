
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211105030230857004"
  display_name = "accTestMG-211105030230857004"
}
