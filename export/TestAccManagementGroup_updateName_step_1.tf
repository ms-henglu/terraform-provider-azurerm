
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220324160526589681"
  display_name = "accTestMG-220324160526589681"
}
