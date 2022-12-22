
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221222034945630763"
  display_name = "accTestMG-221222034945630763"
}
