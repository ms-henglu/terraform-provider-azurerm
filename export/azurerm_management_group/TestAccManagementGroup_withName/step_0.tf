
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230613072212641800"
  display_name = "accTestMG-230613072212641800"
}
