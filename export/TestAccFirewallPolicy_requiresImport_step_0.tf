

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-220121044536964366"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-220121044536964366"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
