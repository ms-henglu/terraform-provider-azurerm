

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ACRTask-230616074517912391"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccrtask230616074517912391"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}


resource "azurerm_container_registry_task" "test" {
  name                  = "quicktask"
  container_registry_id = azurerm_container_registry.test.id
  is_system_task        = true
}
