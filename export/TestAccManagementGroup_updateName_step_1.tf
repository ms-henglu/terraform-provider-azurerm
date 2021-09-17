
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210917031913597313"
  display_name = "accTestMG-210917031913597313"
}
