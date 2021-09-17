
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210917031913598362"
  display_name = "accTestMG-210917031913598362"
}
