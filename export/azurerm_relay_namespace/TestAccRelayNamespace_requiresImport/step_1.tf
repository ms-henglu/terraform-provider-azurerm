

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315123934810251"
  location = "West Europe"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctestrn-240315123934810251"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"
}


resource "azurerm_relay_namespace" "import" {
  name                = azurerm_relay_namespace.test.name
  location            = azurerm_relay_namespace.test.location
  resource_group_name = azurerm_relay_namespace.test.resource_group_name

  sku_name = "Standard"
}
