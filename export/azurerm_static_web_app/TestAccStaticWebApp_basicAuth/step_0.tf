
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031305951764"
  location = "West Europe"
}

resource "azurerm_static_web_app" "test" {
  name                = "acctestSS-240311031305951764"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "acceptance"
  }
}
