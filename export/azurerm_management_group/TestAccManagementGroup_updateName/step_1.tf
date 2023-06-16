
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230616075043389964"
  display_name = "accTestMG-230616075043389964"
}
