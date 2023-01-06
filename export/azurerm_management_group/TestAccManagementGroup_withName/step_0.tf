
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230106031652879275"
  display_name = "accTestMG-230106031652879275"
}
