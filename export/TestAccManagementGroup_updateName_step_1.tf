
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220715014725505256"
  display_name = "accTestMG-220715014725505256"
}
