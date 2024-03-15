
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-240315123453980643"
  display_name = "accTestMG-240315123453980643"
}
