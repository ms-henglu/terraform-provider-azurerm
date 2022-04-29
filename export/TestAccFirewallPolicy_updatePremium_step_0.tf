

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-220429075438831490"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-220429075438831490"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
