
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728032318351203"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn-230728032318351203"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctsub-230728032318351203"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-230728032318351203"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  capacity            = "2"

  network_rulesets {
    default_action = "Deny"
    virtual_network_rule {
      subnet_id = azurerm_subnet.test.id

      ignore_missing_virtual_network_service_endpoint = true
    }
  }
}
