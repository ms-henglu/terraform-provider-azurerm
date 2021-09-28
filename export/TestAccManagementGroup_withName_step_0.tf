
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210928075646917154"
  display_name = "accTestMG-210928075646917154"
}
