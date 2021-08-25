
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210825025949988984"
  display_name = "accTestMG-210825025949988984"
}
