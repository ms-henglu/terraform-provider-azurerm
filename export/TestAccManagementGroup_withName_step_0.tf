
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220722035612406636"
  display_name = "accTestMG-220722035612406636"
}
