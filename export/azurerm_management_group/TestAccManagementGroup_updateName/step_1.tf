
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230810143806118457"
  display_name = "accTestMG-230810143806118457"
}
