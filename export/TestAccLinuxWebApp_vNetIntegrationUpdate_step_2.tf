
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712041934650746"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-220712041934650746"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "B1"
}


resource "azurerm_virtual_network" "test" {
  name                = "vnet-220712041934650746"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_linux_web_app" "test" {
  name                      = "acctestWA-220712041934650746"
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  service_plan_id           = azurerm_service_plan.test.id
  virtual_network_subnet_id = azurerm_subnet.test.id

  site_config {}
}
