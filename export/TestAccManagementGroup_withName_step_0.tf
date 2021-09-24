
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210924004527414762"
  display_name = "accTestMG-210924004527414762"
}
