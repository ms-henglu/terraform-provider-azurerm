
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220513023502000845"
  display_name = "accTestMG-220513023502000845"
}
