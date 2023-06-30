
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230630033516403116"
  display_name = "accTestMG-230630033516403116"
}
