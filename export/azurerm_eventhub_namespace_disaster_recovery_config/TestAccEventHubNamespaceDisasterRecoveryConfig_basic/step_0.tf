
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhub-231016033936831578"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "testa" {
  name                = "acctest-EHN-231016033936831578-a"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub_namespace" "testb" {
  name                = "acctest-EHN-231016033936831578-b"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub_namespace_disaster_recovery_config" "test" {
  name                 = "acctest-EHN-DRC-231016033936831578"
  resource_group_name  = azurerm_resource_group.test.name
  namespace_name       = azurerm_eventhub_namespace.testa.name
  partner_namespace_id = azurerm_eventhub_namespace.testb.id
}
