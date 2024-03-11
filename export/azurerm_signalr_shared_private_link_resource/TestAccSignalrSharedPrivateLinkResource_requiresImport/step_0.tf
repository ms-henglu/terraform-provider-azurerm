

provider "azurerm" {
  features {}
}
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-signalr-240311033138418003"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalr-240311033138418003"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Standard_S1"
    capacity = 1
  }
}

resource "azurerm_key_vault" "test" {
  name                       = "vault240311033138418003"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    certificate_permissions = [
      "ManageContacts",
    ]
    key_permissions = [
      "Create",
    ]
    secret_permissions = [
      "Set",
    ]
  }
}

resource "azurerm_signalr_shared_private_link_resource" "test" {
  name               = "acctest-240311033138418003"
  signalr_service_id = azurerm_signalr_service.test.id
  sub_resource_name  = "vault"
  target_resource_id = azurerm_key_vault.test.id
  request_message    = "please approve"
}
