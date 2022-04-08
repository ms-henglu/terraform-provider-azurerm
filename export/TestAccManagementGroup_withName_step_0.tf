
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220408051529371615"
  display_name = "accTestMG-220408051529371615"
}
