
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220324163620526960"
  display_name = "accTestMG-220324163620526960"
}
