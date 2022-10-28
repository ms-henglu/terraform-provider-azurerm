

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221028164606012706"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapbn3iz6fvfz"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjEwMjgxNjQ2MDZaFw0yMzA0MjYxNjQ2MDZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAdJRFfuh8s/qmnxdA+rosABtcwbq8
DhZOKS0n5UDqw9uGdjMqAXe/XT3o2/pe0ceR5LszvaUv5onEOSJKZ9dqYcIA/mdm
YLzVTRqpbOu2I8PJonmI0gCXfFTgFOjp9YW8kHTG9UYNP76Je2uFImmtIhiclsZ0
amk4N3FcH8LD0e1YzJWjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAJDZJ/0Z
SHCeGLtcMRwQ+VtabD3AN0y+qfUWw31c6mYkfd1YgamNSLUgnIpZneCX/e+D01wd
vxafozir5lYNVFrhAkIBD+vfJsMvBgAwcasDgUq+ayUTgszq0o0DsHCcTlOXm0xe
kQ259gLVlFn6U+WO2bHPpJ6pfJYJTQvzzf7AHm9vIDA=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
