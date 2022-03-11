
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220311032754517982"
  display_name = "accTestMG-220311032754517982"
}
