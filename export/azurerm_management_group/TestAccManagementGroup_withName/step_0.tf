
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221028165223769021"
  display_name = "accTestMG-221028165223769021"
}
