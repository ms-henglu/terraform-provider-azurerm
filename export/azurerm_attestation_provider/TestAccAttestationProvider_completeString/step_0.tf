
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230602030129004752"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapi687wmma64"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA2MDIwMzAxMjlaFw0yMzExMjkwMzAxMjlaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBrzeiYn7MBi5DryCIUXKsAX785FVx
gimZa6sIm5XbAuiWmyHv2mK7+U3vyGnZQUKQFZxQbl35T6LSeZoOb4/3QH0AVgLt
s84U20ZLt06CwA8Xa6cfBsQVlbcO7K2UFeN5i37Mm8KBMXPilddJWerxP0uL/DZr
znOjYZ6xEZyfGpvb1w2jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAI72qXMX
Nw9MUJb1hEwlpa0mHrJQ/CTFTmLhY/gW4XYYP6tVKj1pDVg3HpJipk7zdIg4pMvt
20e4+Z7m/qAdEL85AkIAg8nu2bots1rZwtYXtoa4EnSRvJ6L8HR6j/loPVpVK7R3
b+MFpyFYqnxHVP17lzKfhJyepG1N7VbuJYhI+hN+wLs=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }

  lifecycle {
    ignore_changes = [
      "open_enclave_policy_base64",
      "sgx_enclave_policy_base64",
      "tpm_policy_base64",
    ]
  }
}
