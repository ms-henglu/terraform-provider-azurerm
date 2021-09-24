
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210924011205462775"
  display_name = "accTestMG-210924011205462775"
}
