
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220128082640305039"
  display_name = "accTestMG-220128082640305039"
}
