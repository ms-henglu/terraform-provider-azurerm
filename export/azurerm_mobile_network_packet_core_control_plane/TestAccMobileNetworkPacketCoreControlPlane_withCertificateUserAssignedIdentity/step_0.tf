
	

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-231013043846234835"
  location = "West Europe"
}

resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-231013043846234835"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network_site" "test" {
  name              = "acctest-mns-231013043846234835"
  mobile_network_id = azurerm_mobile_network.test.id
  location          = azurerm_mobile_network.test.location
}


resource "azurerm_databox_edge_device" "test" {
  name                = "acct231013043846234835"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "EdgeP_Base-Standard"
}



data "azurerm_client_config" "test" {}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest-mn-231013043846234835"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_key_vault" "test" {
  name                = "acct-231013043846234835"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.test.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id               = data.azurerm_client_config.test.tenant_id
    object_id               = data.azurerm_client_config.test.object_id
    secret_permissions      = ["Delete", "Get", "Set", "Purge"]
    certificate_permissions = ["Create", "Delete", "Get", "Import", "Purge"]
  }

  access_policy {
    tenant_id               = data.azurerm_client_config.test.tenant_id
    object_id               = azurerm_user_assigned_identity.test.principal_id
    secret_permissions      = ["Delete", "Get", "Set"]
    certificate_permissions = ["Create", "Delete", "Get", "Import"]
  }

}

resource "azurerm_key_vault_certificate" "test" {
  name         = "acctest-mn-231013043846234835"
  key_vault_id = azurerm_key_vault.test.id

  certificate {
    contents = filebase64("testdata/rsa_bundle.pfx")
    password = ""
  }
}

resource "azurerm_mobile_network_packet_core_control_plane" "test" {
  name                              = "acctest-mnpccp-231013043846234835"
  resource_group_name               = azurerm_resource_group.test.name
  location                          = "West Europe"
  sku                               = "G0"
  core_network_technology           = "5GC"
  site_ids                          = [azurerm_mobile_network_site.test.id]
  control_plane_access_name         = "default-interface"
  control_plane_access_ipv4_address = "192.168.1.199"
  control_plane_access_ipv4_gateway = "192.168.1.1"
  control_plane_access_ipv4_subnet  = "192.168.1.0/25"

  local_diagnostics_access {
    authentication_type          = "AAD"
    https_server_certificate_url = azurerm_key_vault_certificate.test.versionless_secret_id
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }

  platform {
    type           = "AKS-HCI"
    edge_device_id = azurerm_databox_edge_device.test.id
  }

  depends_on = [azurerm_mobile_network.test]
}




