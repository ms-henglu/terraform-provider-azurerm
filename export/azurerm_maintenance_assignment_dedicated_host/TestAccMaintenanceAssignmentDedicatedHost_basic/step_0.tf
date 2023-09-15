

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-maint-230915023719414226"
  location = "West Europe"
}

resource "azurerm_maintenance_configuration" "test" {
  name                = "acctest-MC230915023719414226"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope               = "Host"
}

resource "azurerm_dedicated_host_group" "test" {
  name                        = "acctest-DHG-230915023719414226"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  platform_fault_domain_count = 2
}

resource "azurerm_dedicated_host" "test" {
  name                    = "acctest-DH-230915023719414226"
  location                = azurerm_resource_group.test.location
  dedicated_host_group_id = azurerm_dedicated_host_group.test.id
  sku_name                = "DSv3-Type1"
  platform_fault_domain   = 1
}


resource "azurerm_maintenance_assignment_dedicated_host" "test" {
  location                     = azurerm_resource_group.test.location
  maintenance_configuration_id = azurerm_maintenance_configuration.test.id
  dedicated_host_id            = azurerm_dedicated_host.test.id
}
