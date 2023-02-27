

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230227032235666410"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapdes3ekz0kq"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzAyMjcwMzIyMzVaFw0yMzA4MjYwMzIyMzVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAgdD3em5VvzMD2tDT8jCrzAQZy6Pk
pOKBXHYCMHGy8KKMrEh7Yjs8sEDecNFhKWGuG9ur9vkiqGATzvOHRQeoOo0Bwt0/
14Nmi3dlq5xweb0p0M2HSF6mfIbsQwmxGdBWr4cKmGREG07O4b9h2gkDJiKw6xFd
cb1e1NR4Xy3upHoyjP2jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAeEoTlFW
QWxkzi9Tm1fr6EuqV67EloEZ6++Yqt1JANlRtVaxnOy21coPjCO4Ohk6s7Mue8n6
3HTWDHwEFaLjce5zAkIAt1TrGOt/4LcP6/QuS36K9rG8EOa55BBDS2Rxk00cf5C/
iujDqp20H+uGLm/ik3fHJQ+oL5Kcl/Ftkfx3B+xX3i4=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
