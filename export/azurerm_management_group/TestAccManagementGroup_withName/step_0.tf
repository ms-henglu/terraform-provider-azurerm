
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-240112224812685421"
  display_name = "accTestMG-240112224812685421"
}
