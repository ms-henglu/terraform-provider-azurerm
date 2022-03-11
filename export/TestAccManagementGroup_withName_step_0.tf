
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220311042659706528"
  display_name = "accTestMG-220311042659706528"
}
