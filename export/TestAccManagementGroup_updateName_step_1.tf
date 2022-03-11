
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220311042659704449"
  display_name = "accTestMG-220311042659704449"
}
