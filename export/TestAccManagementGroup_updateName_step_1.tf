
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220422025435331219"
  display_name = "accTestMG-220422025435331219"
}
