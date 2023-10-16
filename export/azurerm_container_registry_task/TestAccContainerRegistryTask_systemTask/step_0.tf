

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ACRTask-231016033638159745"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccrtask231016033638159745"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}


resource "azurerm_container_registry_task" "test" {
  name                  = "quicktask"
  container_registry_id = azurerm_container_registry.test.id
  is_system_task        = true
}
