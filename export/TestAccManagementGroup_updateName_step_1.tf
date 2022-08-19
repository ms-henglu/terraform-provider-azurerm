
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220819165433821352"
  display_name = "accTestMG-220819165433821352"
}
