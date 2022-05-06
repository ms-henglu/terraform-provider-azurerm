
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220506005944521476"
  display_name = "accTestMG-220506005944521476"
}
