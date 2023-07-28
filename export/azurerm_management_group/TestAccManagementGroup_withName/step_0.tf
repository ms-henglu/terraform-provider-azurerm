
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230728030126946934"
  display_name = "accTestMG-230728030126946934"
}
