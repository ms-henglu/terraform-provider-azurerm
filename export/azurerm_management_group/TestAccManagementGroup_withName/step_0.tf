
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230825024853955375"
  display_name = "accTestMG-230825024853955375"
}
