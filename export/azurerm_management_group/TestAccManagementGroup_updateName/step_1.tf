
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230113181353644896"
  display_name = "accTestMG-230113181353644896"
}
