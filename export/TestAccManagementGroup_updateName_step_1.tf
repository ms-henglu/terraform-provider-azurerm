
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211015014830819303"
  display_name = "accTestMG-211015014830819303"
}
