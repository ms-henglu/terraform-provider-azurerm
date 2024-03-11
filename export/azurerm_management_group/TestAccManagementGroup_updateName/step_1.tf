
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-240311032526946455"
  display_name = "accTestMG-240311032526946455"
}
