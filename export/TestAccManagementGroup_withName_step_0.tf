
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220407231157737645"
  display_name = "accTestMG-220407231157737645"
}
