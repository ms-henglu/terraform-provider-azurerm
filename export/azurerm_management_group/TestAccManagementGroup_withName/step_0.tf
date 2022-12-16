
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221216013822497146"
  display_name = "accTestMG-221216013822497146"
}
