
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ehnar-231016033936836460-1"
  location = "West Europe"
}

resource "azurerm_resource_group" "test2" {
  name     = "acctestRG-ehnar-231016033936836460-2"
  location = "West US 2"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-231016033936836460"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub_namespace" "test2" {
  name                = "acctesteventhubnamespace2-231016033936836460"
  location            = azurerm_resource_group.test2.location
  resource_group_name = azurerm_resource_group.test2.name
  sku                 = "Standard"
}

resource "azurerm_eventhub_namespace_disaster_recovery_config" "test" {
  name                 = "acctest-EHN-DRC-231016033936836460"
  resource_group_name  = azurerm_resource_group.test.name
  namespace_name       = azurerm_eventhub_namespace.test.name
  partner_namespace_id = azurerm_eventhub_namespace.test2.id
}

resource "azurerm_eventhub_namespace_authorization_rule" "test" {
  name                = "acctest-EHN-AR231016033936836460"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = true
}
