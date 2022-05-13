
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220513180513538478"
  display_name = "accTestMG-220513180513538478"
}
