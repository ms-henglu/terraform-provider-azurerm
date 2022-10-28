
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221028165223761781"
  display_name = "accTestMG-221028165223761781"
}
