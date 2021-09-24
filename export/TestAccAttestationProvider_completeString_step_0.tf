

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210924010701460839"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapp2jjmyu8r9"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTA5MjQwMTA3MDFaFw0yMjAzMjMwMTA3MDFaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAc8pjjPMuABXAfYJ1q4pImrE8d7gX
mQjhvm4n67tKXuOBu2HNBO9i0QJyInXkdjJ4JdFSrBfQayfs0pHVCE7ofmMADVKU
Xz1QbIB0AHLDp6ji1ePMjuJwAAXyohux+i8/tRTzNzDwNVTyzs4CD5heD0CvuWIE
DJXRw83AjB/RLtjM7zijNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAQKaypwm
Vg2xyBcacRwkde/TY6flXwlNH9ZhSuy8QR+FK/PPmQEK+4sjnmaUZvJ1qSQXXsY5
7Qz43RmSvKcQesJWAkIBJf7qvsSgrZsJEc/Qaaah+pStS49TE400Ri7R0eTphUl7
c94nuMpJLX89hFzsxzeJjH69EkBwpuj3LcVaHIupX04=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
