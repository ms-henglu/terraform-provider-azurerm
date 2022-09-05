
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220905050133623409"
  display_name = "accTestMG-220905050133623409"
}
