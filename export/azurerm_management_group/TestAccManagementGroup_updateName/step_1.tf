
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230707004259128836"
  display_name = "accTestMG-230707004259128836"
}
