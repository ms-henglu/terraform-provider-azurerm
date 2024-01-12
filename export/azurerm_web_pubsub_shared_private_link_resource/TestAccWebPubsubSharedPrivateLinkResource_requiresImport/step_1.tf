


provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-240112035201558049"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctestWebPubsub-240112035201558049"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_S1"
  capacity            = 1
}


resource "azurerm_key_vault" "test" {
  name                       = "vault240112035201558049"
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

resource "azurerm_web_pubsub_shared_private_link_resource" "test" {
  name               = "acctest-240112035201558049"
  web_pubsub_id      = azurerm_web_pubsub.test.id
  subresource_name   = "vault"
  target_resource_id = azurerm_key_vault.test.id
}


resource "azurerm_web_pubsub_shared_private_link_resource" "import" {
  name               = azurerm_web_pubsub_shared_private_link_resource.test.name
  web_pubsub_id      = azurerm_web_pubsub_shared_private_link_resource.test.web_pubsub_id
  subresource_name   = azurerm_web_pubsub_shared_private_link_resource.test.subresource_name
  target_resource_id = azurerm_web_pubsub_shared_private_link_resource.test.target_resource_id
}
