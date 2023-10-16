
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ehar-231016033936831419-1"
  location = "West Europe"
}

resource "azurerm_resource_group" "test2" {
  name     = "acctestRG-ehar-231016033936831419-2"
  location = "West US 2"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-231016033936831419"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"
}

resource "azurerm_eventhub_namespace" "test2" {
  name                = "acctesteventhubnamespace2-231016033936831419"
  location            = azurerm_resource_group.test2.location
  resource_group_name = azurerm_resource_group.test2.name

  sku = "Standard"
}

resource "azurerm_eventhub_namespace_disaster_recovery_config" "test" {
  name                 = "acctest-EHN-DRC-231016033936831419"
  resource_group_name  = azurerm_resource_group.test.name
  namespace_name       = azurerm_eventhub_namespace.test.name
  partner_namespace_id = azurerm_eventhub_namespace.test2.id
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-231016033936831419"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  partition_count   = 2
  message_retention = 1
}

resource "azurerm_eventhub_authorization_rule" "test" {
  name                = "acctest-231016033936831419"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = true

  depends_on = [azurerm_eventhub_namespace_disaster_recovery_config.test]
}
