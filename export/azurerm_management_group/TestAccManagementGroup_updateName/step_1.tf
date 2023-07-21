
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230721015513216141"
  display_name = "accTestMG-230721015513216141"
}
