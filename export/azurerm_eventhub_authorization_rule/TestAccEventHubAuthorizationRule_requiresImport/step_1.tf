

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810143458403979"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-230810143458403979"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-230810143458403979"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  partition_count   = 2
  message_retention = 1
}

resource "azurerm_eventhub_authorization_rule" "test" {
  name                = "acctest-230810143458403979"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = true
}


resource "azurerm_eventhub_authorization_rule" "import" {
  name                = azurerm_eventhub_authorization_rule.test.name
  namespace_name      = azurerm_eventhub_authorization_rule.test.namespace_name
  eventhub_name       = azurerm_eventhub_authorization_rule.test.eventhub_name
  resource_group_name = azurerm_eventhub_authorization_rule.test.resource_group_name
  listen              = azurerm_eventhub_authorization_rule.test.listen
  send                = azurerm_eventhub_authorization_rule.test.send
  manage              = azurerm_eventhub_authorization_rule.test.manage
}
