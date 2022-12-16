

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221216013106091006"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapuwonzyl10c"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjEyMTYwMTMxMDZaFw0yMzA2MTQwMTMxMDZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBtcPipV8DRwWi2FTLNNU+mGkiDWSy
gBFlc6wK5MqTWaTVP6TjqPGLOeWYWMYyLIP6gsZvgxVVXX6IejNQEkTP/E4BDNq+
JUE5iawSNUdfqcCzABhEszrA9r+xPcYKq98baRfWk8xcgIxVRO7uNiA3Ob6KXqU7
NNIYVvKIMoTW6XVysmejNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAaLibFDF
ndPDlPQNW9rJ6WqXpBMwMIy/oPKEht/6/k6ydysziPvmj9wKZmkvc989Bg+q1mHC
sDJAYGn3JMM23lrZAkIAnAp0FUmqS9h3K0gNER8ZpexSFXlDsPzCAm8Y7Sod0YkI
cEqUleJQ7Yc0WFy1aWTCuX1h/AdWLyUuhAQDZXgPQOo=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
