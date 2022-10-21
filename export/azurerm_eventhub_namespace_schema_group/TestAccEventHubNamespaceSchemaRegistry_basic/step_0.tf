
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhubSG-221021034126620819"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-221021034126620819"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub_namespace_schema_group" "test" {
  name                 = "acctestsg-221021034126620819"
  namespace_id         = azurerm_eventhub_namespace.test.id
  schema_compatibility = "Forward"
  schema_type          = "Avro"
}
