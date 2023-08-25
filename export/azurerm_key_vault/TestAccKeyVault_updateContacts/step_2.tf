
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-kv-230825024721342425"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "vault230825024721342425"
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

  contact {
    email = "example@example.com"
    name  = "example"
    phone = "01234567890"
  }
}
