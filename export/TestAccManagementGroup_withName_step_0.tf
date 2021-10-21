
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211021235215491339"
  display_name = "accTestMG-211021235215491339"
}
