

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014737350384"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet211015014737350384"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test_a" {
  name                 = "acctestsubneta211015014737350384"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
  service_endpoints    = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "test_b" {
  name                 = "acctestsubnetb211015014737350384"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.4.0/24"
  service_endpoints    = ["Microsoft.KeyVault"]
}


resource "azurerm_key_vault" "test" {
  name                       = "vault211015014737350384"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "create",
    ]

    secret_permissions = [
      "set",
    ]
  }

  network_acls {
    default_action             = "Allow"
    bypass                     = "AzureServices"
    ip_rules                   = ["123.0.0.102/32", "123.0.0.101"]
    virtual_network_subnet_ids = [azurerm_subnet.test_a.id]
  }
}
