
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210826023554727995"
  display_name = "accTestMG-210826023554727995"
}
