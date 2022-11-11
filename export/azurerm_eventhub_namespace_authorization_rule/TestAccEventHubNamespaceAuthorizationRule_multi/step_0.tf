

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhub-221111013553867997"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctest-EHN-221111013553867997"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"
}

resource "azurerm_eventhub_namespace_authorization_rule" "test" {
  name                = "acctest-EHN-AR221111013553867997"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = true
}


resource "azurerm_eventhub_namespace_authorization_rule" "test1" {
  name                = "acctestruleone-221111013553867997"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  send   = true
  listen = true
  manage = false
}

resource "azurerm_eventhub_namespace_authorization_rule" "test2" {
  name                = "acctestruletwo-221111013553867997"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  send   = true
  listen = true
  manage = false
}

resource "azurerm_eventhub_namespace_authorization_rule" "test3" {
  name                = "acctestrulethree-221111013553867997"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  send   = true
  listen = true
  manage = false
}
