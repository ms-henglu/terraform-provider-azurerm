
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_client_config" "test" {}

data "azuread_service_principal" "test" {
  display_name = "Microsoft Azure App Service"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestwebcert210917032332560398"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "acct210917032332560398"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  soft_delete_enabled = true

  tenant_id = data.azurerm_client_config.test.tenant_id

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.test.tenant_id
    object_id = data.azurerm_client_config.test.object_id

    secret_permissions = [
      "delete",
      "get",
      "purge",
      "set",
    ]

    certificate_permissions = [
      "create",
      "delete",
      "get",
      "purge",
      "import",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.test.tenant_id
    object_id = data.azuread_service_principal.test.object_id

    secret_permissions = [
      "get",
    ]

    certificate_permissions = [
      "get",
    ]
  }
}

resource "azurerm_key_vault_certificate" "test" {
  name         = "acctest210917032332560398"
  key_vault_id = azurerm_key_vault.test.id

  certificate {
    contents = filebase64("testdata/app_service_certificate.pfx")
    password = "terraform"
  }

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }
}

resource "azurerm_app_service_certificate" "test" {
  name                = "acctest210917032332560398"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  key_vault_secret_id = azurerm_key_vault_certificate.test.id
}
