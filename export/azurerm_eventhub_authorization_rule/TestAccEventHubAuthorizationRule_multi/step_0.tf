

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222034703914647"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-221222034703914647"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-221222034703914647"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  partition_count   = 2
  message_retention = 1
}

resource "azurerm_eventhub_authorization_rule" "test" {
  name                = "acctest-221222034703914647"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = true
}


resource "azurerm_eventhub_authorization_rule" "test1" {
  name                = "acctestruleone-221222034703914647"
  eventhub_name       = azurerm_eventhub.test.name
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  send                = true
  listen              = true
}

resource "azurerm_eventhub_authorization_rule" "test2" {
  name                = "acctestruletwo-221222034703914647"
  eventhub_name       = azurerm_eventhub.test.name
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  send                = true
  listen              = true
}

resource "azurerm_eventhub_authorization_rule" "test3" {
  name                = "acctestrulethree-221222034703914647"
  eventhub_name       = azurerm_eventhub.test.name
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  send                = true
  listen              = true
}
