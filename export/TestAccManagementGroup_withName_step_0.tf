
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211217035522342971"
  display_name = "accTestMG-211217035522342971"
}
