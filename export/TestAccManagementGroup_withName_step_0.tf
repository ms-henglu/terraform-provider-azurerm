
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220124125327963779"
  display_name = "accTestMG-220124125327963779"
}
