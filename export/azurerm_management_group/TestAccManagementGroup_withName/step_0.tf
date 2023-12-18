
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-231218072110402217"
  display_name = "accTestMG-231218072110402217"
}
