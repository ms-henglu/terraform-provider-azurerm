
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-231218072110407963"
  display_name = "accTestMG-231218072110407963"
}
