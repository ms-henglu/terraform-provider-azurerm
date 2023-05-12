
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230512004332063838"
  display_name = "accTestMG-230512004332063838"
}
