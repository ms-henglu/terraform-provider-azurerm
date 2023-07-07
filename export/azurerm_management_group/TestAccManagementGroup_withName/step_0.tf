
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230707004259127264"
  display_name = "accTestMG-230707004259127264"
}
