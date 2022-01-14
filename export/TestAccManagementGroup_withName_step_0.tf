
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220114014447391117"
  display_name = "accTestMG-220114014447391117"
}
