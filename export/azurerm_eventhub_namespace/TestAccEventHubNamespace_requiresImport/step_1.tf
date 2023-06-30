

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eh-230630033215164688"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-230630033215164688"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}


resource "azurerm_eventhub_namespace" "import" {
  name                = azurerm_eventhub_namespace.test.name
  location            = azurerm_eventhub_namespace.test.location
  resource_group_name = azurerm_eventhub_namespace.test.resource_group_name
  sku                 = azurerm_eventhub_namespace.test.sku
}
