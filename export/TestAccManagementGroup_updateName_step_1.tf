
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210924004527414893"
  display_name = "accTestMG-210924004527414893"
}
