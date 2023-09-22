

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appserviceplan-230922060536073886"
  location = "West Europe"
}

resource "azurerm_resource_group" "test2" {
  name     = "acctestRG2-ase-230922060536073886"
  location = "West Europe"
}


resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-230922060536073886"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-subnet-230922060536073886"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
  delegation {
    name = "asedelegation"
    service_delegation {
      name    = "Microsoft.Web/hostingEnvironments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_app_service_environment_v3" "test" {
  name                = "acctest-ase-230922060536073886"
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.test.id
}

resource "azurerm_service_plan" "test" {
  name                = "acctest-SP-230922060536073886"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Windows"
  sku_name            = "I1v2"

  app_service_environment_id = azurerm_app_service_environment_v3.test.id

  tags = {
    environment = "AccTest"
    Foo         = "bar"
  }
}


resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-230922060536073886"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}
