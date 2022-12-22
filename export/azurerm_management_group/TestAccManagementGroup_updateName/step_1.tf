
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221222034945631261"
  display_name = "accTestMG-221222034945631261"
}
