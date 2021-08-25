
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210825044959056593"
  display_name = "accTestMG-210825044959056593"
}
