
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220712042514143052"
  display_name = "accTestMG-220712042514143052"
}
