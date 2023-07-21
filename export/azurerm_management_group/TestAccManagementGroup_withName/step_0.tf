
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230721012008314537"
  display_name = "accTestMG-230721012008314537"
}
