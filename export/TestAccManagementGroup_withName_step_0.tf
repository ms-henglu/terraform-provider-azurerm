
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220204093235209270"
  display_name = "accTestMG-220204093235209270"
}
