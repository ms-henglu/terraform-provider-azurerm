
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220726002146614497"
  display_name = "accTestMG-220726002146614497"
}
