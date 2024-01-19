
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-240119025338076526"
  display_name = "accTestMG-240119025338076526"
}
