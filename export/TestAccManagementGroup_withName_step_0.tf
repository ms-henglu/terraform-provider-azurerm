
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220905050133622685"
  display_name = "accTestMG-220905050133622685"
}
