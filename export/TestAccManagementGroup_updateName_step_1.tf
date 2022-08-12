
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220812015405916755"
  display_name = "accTestMG-220812015405916755"
}
