
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230505050802350105"
  display_name = "accTestMG-230505050802350105"
}
