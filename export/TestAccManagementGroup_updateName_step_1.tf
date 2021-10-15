
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211015014454604749"
  display_name = "accTestMG-211015014454604749"
}
