

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhub-230707003932340398"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctest-EHN-230707003932340398"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"
}

resource "azurerm_eventhub_namespace_authorization_rule" "test" {
  name                = "acctest-EHN-AR230707003932340398"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = true
}


resource "azurerm_eventhub_namespace_authorization_rule" "import" {
  name                = azurerm_eventhub_namespace_authorization_rule.test.name
  namespace_name      = azurerm_eventhub_namespace_authorization_rule.test.namespace_name
  resource_group_name = azurerm_eventhub_namespace_authorization_rule.test.resource_group_name
  listen              = azurerm_eventhub_namespace_authorization_rule.test.listen
  send                = azurerm_eventhub_namespace_authorization_rule.test.send
  manage              = azurerm_eventhub_namespace_authorization_rule.test.manage
}
