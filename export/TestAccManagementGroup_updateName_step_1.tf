
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220811053528929631"
  display_name = "accTestMG-220811053528929631"
}
