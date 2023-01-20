
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230120054835825551"
  display_name = "accTestMG-230120054835825551"
}
