
provider "azurerm" {
  features {}
}

provider "azuread" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825032057928939"
  location = "West Europe"
}

data "azurerm_client_config" "current" {
}

resource "azuread_application" "cluster_explorer" {
  name                       = "${azurerm_resource_group.test.name}-explorer-AAD"
  homepage                   = "https://example:19080/Explorer/index.html"
  identifier_uris            = ["https://example:19080/Explorer/index.html"]
  reply_urls                 = ["https://example:19080/Explorer/index.html"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true

  # https://blogs.msdn.microsoft.com/aaddevsup/2018/06/06/guid-table-for-windows-azure-active-directory-permissions/
  # https://shawntabrizi.com/aad/common-microsoft-resources-azure-active-directory/
  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    resource_access {
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "cluster_explorer" {
  application_id = azuread_application.cluster_explorer.application_id
}

resource "azuread_application" "cluster_console" {
  name                       = "${azurerm_resource_group.test.name}-console-AAD"
  type                       = "native"
  reply_urls                 = ["urn:ietf:wg:oauth:2.0:oob"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true

  # https://blogs.msdn.microsoft.com/aaddevsup/2018/06/06/guid-table-for-windows-azure-active-directory-permissions/
  # https://shawntabrizi.com/aad/common-microsoft-resources-azure-active-directory/
  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    resource_access {
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
  }

  required_resource_access {
    resource_app_id = azuread_application.cluster_explorer.application_id

    resource_access {
      id   = azuread_application.cluster_explorer.oauth2_permissions[0].id
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "cluster_console" {
  application_id = azuread_application.cluster_console.application_id
}

resource "azurerm_service_fabric_cluster" "test" {
  name                = "acctest-210825032057928939"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  reliability_level   = "Bronze"
  upgrade_mode        = "Automatic"
  vm_image            = "Windows"
  management_endpoint = "https://example:19080"

  certificate {
    thumbprint      = "3341DB6CF2AF72C611DF3BE3721A653AF1D43ECD50F584F828793DBE9103C3EE"
    x509_store_name = "My"
  }

  azure_active_directory {
    tenant_id              = data.azurerm_client_config.current.tenant_id
    cluster_application_id = azuread_application.cluster_explorer.application_id
    client_application_id  = azuread_application.cluster_console.application_id
  }

  fabric_settings {
    name = "Security"

    parameters = {
      "ClusterProtectionLevel" = "EncryptAndSign"
    }
  }

  node_type {
    name                 = "system"
    instance_count       = 3
    is_primary           = true
    client_endpoint_port = 19000
    http_endpoint_port   = 19080
  }
}
