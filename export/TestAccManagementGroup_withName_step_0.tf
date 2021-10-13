
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211013072105760115"
  display_name = "accTestMG-211013072105760115"
}
