

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122240614047"
  location = "West Europe"
}

resource "azurerm_static_web_app" "test" {
  name                = "acctestSS-240315122240614047"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "acceptance"
  }
}


resource "azurerm_static_web_app" "import" {
  name                = azurerm_static_web_app.test.name
  location            = azurerm_static_web_app.test.location
  resource_group_name = azurerm_static_web_app.test.resource_group_name
  sku_size            = azurerm_static_web_app.test.sku_size
  sku_tier            = azurerm_static_web_app.test.sku_tier
}
