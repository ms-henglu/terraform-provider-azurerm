
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230519075136603605"
  display_name = "accTestMG-230519075136603605"
}
