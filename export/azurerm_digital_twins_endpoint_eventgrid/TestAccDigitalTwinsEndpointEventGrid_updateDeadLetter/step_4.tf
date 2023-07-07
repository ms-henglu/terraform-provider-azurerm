



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-230707010320167187"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-230707010320167187"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-230707010320167187"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_storage_account" "test" {
  name                     = "acctestacc8pq81"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_digital_twins_endpoint_eventgrid" "test" {
  name                                 = "acctest-EG-230707010320167187"
  digital_twins_id                     = azurerm_digital_twins_instance.test.id
  eventgrid_topic_endpoint             = azurerm_eventgrid_topic.test.endpoint
  eventgrid_topic_primary_access_key   = azurerm_eventgrid_topic.test.primary_access_key
  eventgrid_topic_secondary_access_key = azurerm_eventgrid_topic.test.secondary_access_key

}
