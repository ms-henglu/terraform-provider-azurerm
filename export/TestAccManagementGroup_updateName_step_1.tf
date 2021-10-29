
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211029015826947382"
  display_name = "accTestMG-211029015826947382"
}
