
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220610022815559063"
  display_name = "accTestMG-220610022815559063"
}
