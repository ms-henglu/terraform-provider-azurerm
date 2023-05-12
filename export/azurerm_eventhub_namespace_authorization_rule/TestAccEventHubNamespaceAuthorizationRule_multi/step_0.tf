

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhub-230512010720331637"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctest-EHN-230512010720331637"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"
}

resource "azurerm_eventhub_namespace_authorization_rule" "test" {
  name                = "acctest-EHN-AR230512010720331637"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = true
}


resource "azurerm_eventhub_namespace_authorization_rule" "test1" {
  name                = "acctestruleone-230512010720331637"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  send   = true
  listen = true
  manage = false
}

resource "azurerm_eventhub_namespace_authorization_rule" "test2" {
  name                = "acctestruletwo-230512010720331637"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  send   = true
  listen = true
  manage = false
}

resource "azurerm_eventhub_namespace_authorization_rule" "test3" {
  name                = "acctestrulethree-230512010720331637"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  send   = true
  listen = true
  manage = false
}
