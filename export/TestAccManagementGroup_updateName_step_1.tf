
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210825044942455818"
  display_name = "accTestMG-210825044942455818"
}
