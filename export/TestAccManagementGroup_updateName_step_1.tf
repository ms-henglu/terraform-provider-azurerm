
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211203161610038819"
  display_name = "accTestMG-211203161610038819"
}
