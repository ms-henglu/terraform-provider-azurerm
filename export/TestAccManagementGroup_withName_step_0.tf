
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210924011205460999"
  display_name = "accTestMG-210924011205460999"
}
