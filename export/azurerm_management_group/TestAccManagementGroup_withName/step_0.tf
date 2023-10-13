
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-231013043807174416"
  display_name = "accTestMG-231013043807174416"
}
