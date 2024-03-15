

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122207541162-sf"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240315122207541162-sf"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_certificate" "test" {
  name                = "acctest-cert-240315122207541162"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  data                = filebase64("testdata/keyvaultcert.pfx")
  password            = ""
}

resource "azurerm_api_management_backend" "test" {
  name                = "acctestapi-240315122207541162"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  protocol            = "http"
  url                 = "fabric:/mytestapp/acctest"
  service_fabric_cluster {
    client_certificate_thumbprint = azurerm_api_management_certificate.test.thumbprint
    server_x509_name {
      name                          = "test"
      issuer_certificate_thumbprint = azurerm_api_management_certificate.test.thumbprint
    }
    management_endpoints = [
      "https://acctestsf.com",
    ]
    max_partition_resolution_retries = 5
  }
}
