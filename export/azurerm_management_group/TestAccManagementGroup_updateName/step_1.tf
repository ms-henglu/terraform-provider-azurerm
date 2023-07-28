
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230728030126940332"
  display_name = "accTestMG-230728030126940332"
}
