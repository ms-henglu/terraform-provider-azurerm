
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220506020146990616"
  display_name = "accTestMG-220506020146990616"
}
