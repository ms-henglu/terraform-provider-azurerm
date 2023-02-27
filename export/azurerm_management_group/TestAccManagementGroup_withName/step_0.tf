
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230227175708010216"
  display_name = "accTestMG-230227175708010216"
}
