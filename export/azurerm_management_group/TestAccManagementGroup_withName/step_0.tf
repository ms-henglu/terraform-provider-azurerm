
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230106034725149383"
  display_name = "accTestMG-230106034725149383"
}
