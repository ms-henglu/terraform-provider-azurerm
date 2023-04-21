
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230421022503072315"
  display_name = "accTestMG-230421022503072315"
}
