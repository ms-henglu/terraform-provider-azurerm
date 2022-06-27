
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220627130020281315"
  display_name = "accTestMG-220627130020281315"
}
