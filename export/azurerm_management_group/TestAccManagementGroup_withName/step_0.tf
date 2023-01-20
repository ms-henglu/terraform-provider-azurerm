
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230120054835820736"
  display_name = "accTestMG-230120054835820736"
}
