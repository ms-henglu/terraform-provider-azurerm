
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-240112034714984528"
  display_name = "accTestMG-240112034714984528"
}
