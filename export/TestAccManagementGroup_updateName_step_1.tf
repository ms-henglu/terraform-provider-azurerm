
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220204093235208240"
  display_name = "accTestMG-220204093235208240"
}
