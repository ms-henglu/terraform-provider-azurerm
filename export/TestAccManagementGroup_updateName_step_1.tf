
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220121044722400701"
  display_name = "accTestMG-220121044722400701"
}
