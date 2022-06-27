

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-220627131917444082"
  location = "West Europe"
}


resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-220627131917444082"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
