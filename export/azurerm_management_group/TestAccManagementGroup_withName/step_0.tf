
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230414021705070880"
  display_name = "accTestMG-230414021705070880"
}
