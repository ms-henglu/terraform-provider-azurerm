

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ACRTask-220916011243722118"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccrtask220916011243722118"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}


resource "azurerm_container_registry_task" "test" {
  name                  = "quicktask"
  container_registry_id = azurerm_container_registry.test.id
  is_system_task        = true
}
