
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230106034725146173"
  display_name = "accTestMG-230106034725146173"
}
