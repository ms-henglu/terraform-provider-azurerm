
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220324180509266043"
  display_name = "accTestMG-220324180509266043"
}
