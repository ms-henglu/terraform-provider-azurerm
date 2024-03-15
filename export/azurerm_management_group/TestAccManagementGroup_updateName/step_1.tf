
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-240315123453983050"
  display_name = "accTestMG-240315123453983050"
}
