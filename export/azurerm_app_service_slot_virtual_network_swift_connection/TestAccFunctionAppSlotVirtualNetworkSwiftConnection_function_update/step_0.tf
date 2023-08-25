

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-functionapp-230825025504283656"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VNET-230825025504283656"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  lifecycle {
    ignore_changes = ["ddos_protection_plan"]
  }
}

resource "azurerm_subnet" "test1" {
  name                 = "acctestSubnet1"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "acctestdelegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "test2" {
  name                 = "acctestSubnet2"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "acctestdelegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsacvjai"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctest-ASP-230825025504283656"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "test" {
  name                       = "acctest-FA-230825025504283656"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  app_service_plan_id        = azurerm_app_service_plan.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key
}

resource "azurerm_function_app_slot" "test-staging" {
  name                       = "acctest-FA-230825025504283656-staging"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  app_service_plan_id        = azurerm_app_service_plan.test.id
  function_app_name          = azurerm_function_app.test.name
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key
}


resource "azurerm_app_service_slot_virtual_network_swift_connection" "test" {
  slot_name      = azurerm_function_app_slot.test-staging.name
  app_service_id = azurerm_function_app.test.id
  subnet_id      = azurerm_subnet.test1.id
}
