
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-231016034245706681"
  display_name = "accTestMG-231016034245706681"
}
