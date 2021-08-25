
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210825025949985991"
  display_name = "accTestMG-210825025949985991"
}
