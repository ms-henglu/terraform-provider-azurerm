
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230113181353646257"
  display_name = "accTestMG-230113181353646257"
}
