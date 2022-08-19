
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220819165433823229"
  display_name = "accTestMG-220819165433823229"
}
