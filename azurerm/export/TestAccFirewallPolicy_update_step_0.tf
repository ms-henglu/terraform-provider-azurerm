

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-220627122655537291"
  location = "West Europe"
}


resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-220627122655537291"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
