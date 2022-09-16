
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220916011716251038"
  display_name = "accTestMG-220916011716251038"
}
