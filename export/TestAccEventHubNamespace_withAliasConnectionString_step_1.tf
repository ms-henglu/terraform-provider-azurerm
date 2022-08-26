
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ehn-220826002735989533-1"
  location = "West Europe"
}

resource "azurerm_resource_group" "test2" {
  name     = "acctestRG-ehn-220826002735989533"
  location = "West US 2"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-220826002735989533"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"
}

resource "azurerm_eventhub_namespace" "test2" {
  name                = "acctesteventhubnamespace2-220826002735989533"
  location            = azurerm_resource_group.test2.location
  resource_group_name = azurerm_resource_group.test2.name

  sku = "Standard"
}

resource "azurerm_eventhub_namespace_disaster_recovery_config" "test" {
  name                 = "acctest-EHN-DRC-220826002735989533"
  resource_group_name  = azurerm_resource_group.test.name
  namespace_name       = azurerm_eventhub_namespace.test.name
  partner_namespace_id = azurerm_eventhub_namespace.test2.id
}
