
provider "azurerm" {
  features {}
}

provider "azuread" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034724808648"
  location = "West Europe"
}

data "azurerm_client_config" "current" {
}

data "azuread_domains" "test" {
}

resource "azuread_application" "cluster_explorer" {
  display_name    = "${azurerm_resource_group.test.name}-explorer-AAD"
  identifier_uris = ["https://test-8ns4v.${data.azuread_domains.test.domains[0].domain_name}:19080/Explorer/index.html"]
  web {
    homepage_url  = "https://example:19080/Explorer/index.html"
    redirect_uris = ["https://example:19080/Explorer/index.html"]

    implicit_grant {
      access_token_issuance_enabled = true
    }
  }
  sign_in_audience = "AzureADMyOrg"


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
  display_name     = "${azurerm_resource_group.test.name}-console-AAD"
  sign_in_audience = "AzureADMyOrg"
  web {
    redirect_uris = ["urn:ietf:wg:oauth:2.0:oob"]

    implicit_grant {
      access_token_issuance_enabled = true
    }
  }

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
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6" # sign in and user profile permission ctx https://github.com/Azure/azure-cli/issues/7925
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "cluster_console" {
  application_id = azuread_application.cluster_console.application_id
}

resource "azurerm_service_fabric_cluster" "test" {
  name                = "acctest-231016034724808648"
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
