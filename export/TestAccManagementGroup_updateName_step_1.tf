
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211119051108074617"
  display_name = "accTestMG-211119051108074617"
}
