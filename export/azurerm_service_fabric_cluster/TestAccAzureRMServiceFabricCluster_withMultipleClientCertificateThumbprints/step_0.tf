
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cluster-240311033114759503"
  location = "West Europe"
}

resource "azurerm_service_fabric_cluster" "test" {
  name                = "acctest-cluster-240311033114759503"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  reliability_level   = "Bronze"
  upgrade_mode        = "Automatic"
  vm_image            = "Windows"
  management_endpoint = "https://example:80"

  certificate {
    thumbprint      = "3341DB6CF2AF72C611DF3BE3721A653AF1D43ECD50F584F828793DBE9103C3EE"
    x509_store_name = "My"
  }

  client_certificate_thumbprint {
    thumbprint = "1341DB6CF2AF72C611DF3BE3721A653AF1D43ECD50F584F828793DBE9103C3EE"
    is_admin   = true
  }

  client_certificate_thumbprint {
    thumbprint = "2341DB6CF2AF72C611DF3BE3721A653AF1D43ECD50F584F828793DBE9103C3EE"
    is_admin   = false
  }

  client_certificate_thumbprint {
    thumbprint = "3341DB6CF2AF72C611DF3BE3721A653AF1D43ECD50F584F828793DBE9103C3EE"
    is_admin   = true
  }

  fabric_settings {
    name = "Security"

    parameters = {
      "ClusterProtectionLevel" = "EncryptAndSign"
    }
  }

  node_type {
    name                 = "first"
    instance_count       = 3
    is_primary           = true
    client_endpoint_port = 2020
    http_endpoint_port   = 80
  }
}
