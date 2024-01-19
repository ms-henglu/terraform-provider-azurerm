

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appserviceplan-240119024436543934"
  location = "West Europe"
}

resource "azurerm_resource_group" "test2" {
  name     = "acctestRG2-ase-240119024436543934"
  location = "West Europe"
}


resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-240119024436543934"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-subnet-240119024436543934"
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
  name                = "acctest-ase-240119024436543934"
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.test.id
}

resource "azurerm_service_plan" "test" {
  name                = "acctest-SP-240119024436543934"
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


resource "azurerm_storage_account" "test" {
  name                     = "acctestsavokgf"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_windows_function_app" "test" {
  name                = "acctest-WFA-240119024436543934"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {
    vnet_route_all_enabled = true
  }
}

resource "azurerm_windows_function_app_slot" "test" {
  name                       = "acctest-WFAS-240119024436543934"
  function_app_id            = azurerm_windows_function_app.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {
    vnet_route_all_enabled = true
  }
}

