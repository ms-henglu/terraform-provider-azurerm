
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230512004332060848"
  display_name = "accTestMG-230512004332060848"
}
