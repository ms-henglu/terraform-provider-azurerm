
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221117231143142182"
  display_name = "accTestMG-221117231143142182"
}
