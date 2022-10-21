

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221021030835146702"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap6lta9mux20"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjEwMjEwMzA4MzVaFw0yMzA0MTkwMzA4MzVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBtsm7A5XbnY+QrEQ8CmUbSpJ6hXjW
DS48V8X/j/y4JG2tXEROKFp6mup/PlUsnuH0LX0TWx9c8KpprLtFoYD1TzMBehlG
SJIneVCLatYU1DEZpy/1WCSyN+pv4bLI8/hVN6e6O2BS0gJQQ5FG+S7Ii+fHFCq4
u+/mJTfLbp0v0C8kKKqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBWvU/J7uT
MxToBeJWtLomadrCRyALXGx49/Vnq6EM2LW76Q986uxQGp0GEWi7B72cuONnoYvK
vtvishlP1S+U8OMCQgCP/Zt8gMBkMtKTTOs17QbxY5ARp0sAAJkOig2YA7KHslqp
/ib3+iEnvHeY129q2mD5wvgpjyTydiordQLSio/E1A==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
