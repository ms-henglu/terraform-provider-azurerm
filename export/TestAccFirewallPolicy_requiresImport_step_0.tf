

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-211013071906783742"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-211013071906783742"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
