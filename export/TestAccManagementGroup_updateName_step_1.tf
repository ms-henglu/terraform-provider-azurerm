
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220726002146617981"
  display_name = "accTestMG-220726002146617981"
}
