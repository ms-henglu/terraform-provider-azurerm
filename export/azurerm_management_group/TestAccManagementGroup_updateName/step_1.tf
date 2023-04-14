
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230414021705072446"
  display_name = "accTestMG-230414021705072446"
}
