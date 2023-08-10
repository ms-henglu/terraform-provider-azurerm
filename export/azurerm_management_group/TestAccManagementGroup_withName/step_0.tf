
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230810143806113459"
  display_name = "accTestMG-230810143806113459"
}
