
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220204060310665226"
  display_name = "accTestMG-220204060310665226"
}
