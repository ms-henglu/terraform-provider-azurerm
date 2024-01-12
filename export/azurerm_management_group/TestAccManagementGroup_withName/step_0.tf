
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-240112034714985717"
  display_name = "accTestMG-240112034714985717"
}
