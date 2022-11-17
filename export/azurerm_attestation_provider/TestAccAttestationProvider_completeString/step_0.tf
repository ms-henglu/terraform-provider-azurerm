

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221117230512482322"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapcl8p1jj6cu"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjExMTcyMzA1MTJaFw0yMzA1MTYyMzA1MTJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAjy6fVPAlSBJGCfyqPaQkGswwFLek
rxWbr2f77YsJWcfGL1cpbhOoI5U4RnCDAVcKc7dxWCvRXhx4G8/MTHKEGIoAW9zy
KXlzQucMXbUuXo24krLXvLZ9/01ZXgUgxi+TQZ0y7T0KhcUgT8PZ40V354+DmO8I
MK9FYWSBWInIGFn9uiajNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAVInVf6J
o7GxFUKpXCtZwWdPKVYuGTtr1zOOS4fBJDlcFx1YgHxVa1/ndntkLL3Nkaypgp3v
JB8T4Z40SAk5Kwd7AkIBAthoVlr4u4fHvyeisg/EoquBdhmIcU+IGsiOZc8SNzAQ
VAIWCpxDaxh8BdI2bKVrk0azRr24g0RTrJNXOvfQX0o=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
