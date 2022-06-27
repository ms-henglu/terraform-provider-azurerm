
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220627124411551239"
  display_name = "accTestMG-220627124411551239"
}
