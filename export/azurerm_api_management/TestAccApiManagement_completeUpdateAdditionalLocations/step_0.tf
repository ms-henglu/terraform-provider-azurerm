
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test1" {
  name     = "acctestRG-api1-240112033744193951"
  location = "West Europe"
}

resource "azurerm_resource_group" "test2" {
  name     = "acctestRG-api2-240112033744193951"
  location = "West US 2"
}

resource "azurerm_resource_group" "test3" {
  name     = "acctestRG-api3-240112033744193951"
  location = "East US 2"
}

resource "azurerm_api_management" "test" {
  name                      = "acctestAM-240112033744193951"
  publisher_name            = "pub1"
  publisher_email           = "pub1@email.com"
  notification_sender_email = "notification@email.com"

  sku_name = "Premium_2"

  additional_location {
    zones    = []
    capacity = 1
    location = azurerm_resource_group.test2.location
  }

  additional_location {
    zones    = []
    location = azurerm_resource_group.test3.location
  }

  certificate {
    encoded_certificate  = filebase64("testdata/api_management_api_test.pfx")
    certificate_password = "terraform"
    store_name           = "CertificateAuthority"
  }

  certificate {
    encoded_certificate  = filebase64("testdata/api_management_api_test.pfx")
    certificate_password = "terraform"
    store_name           = "Root"
  }

  certificate {
    encoded_certificate = filebase64("testdata/api_management_api_test.cer")
    store_name          = "Root"
  }

  certificate {
    encoded_certificate = filebase64("testdata/api_management_api_test.cer")
    store_name          = "CertificateAuthority"
  }

  protocols {
    enable_http2 = true
  }

  security {
    enable_backend_tls11                                = true
    enable_backend_ssl30                                = true
    enable_backend_tls10                                = true
    enable_frontend_ssl30                               = true
    enable_frontend_tls10                               = true
    enable_frontend_tls11                               = true
    tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = true
    tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = true
    tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = true
    tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = true
    tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = true
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = true
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = true
    tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = true
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = true
    triple_des_ciphers_enabled                          = true
  }

  hostname_configuration {
    proxy {
      host_name                    = "acctestAM-240112033744193951.azure-api.net"
      negotiate_client_certificate = true
    }

    proxy {
      host_name                    = "api.terraform.io"
      certificate                  = filebase64("testdata/api_management_api_test.pfx")
      certificate_password         = "terraform"
      default_ssl_binding          = true
      negotiate_client_certificate = false
    }

    proxy {
      host_name                    = "api2.terraform.io"
      certificate                  = filebase64("testdata/api_management_api2_test.pfx")
      certificate_password         = "terraform"
      negotiate_client_certificate = true
    }

    portal {
      host_name            = "portal.terraform.io"
      certificate          = filebase64("testdata/api_management_portal_test.pfx")
      certificate_password = "terraform"
    }

    developer_portal {
      host_name            = "developer-portal.terraform.io"
      certificate          = filebase64("testdata/api_management_developer_portal_test.pfx")
      certificate_password = "terraform"
    }
  }

  tags = {
    "Acceptance" = "Test"
  }

  location            = azurerm_resource_group.test1.location
  resource_group_name = azurerm_resource_group.test1.name
}
