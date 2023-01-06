
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230106031652877387"
  display_name = "accTestMG-230106031652877387"
}
