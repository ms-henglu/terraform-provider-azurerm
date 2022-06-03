

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220603004538627668"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap76gadi9ghz"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA2MDMwMDQ1MzhaFw0yMjExMzAwMDQ1MzhaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB+XeVT1wZGD57DA23ljYS1tl8QFQ5
tzJ1moyBQ7NxotWAMDuxnu+AY7lYdlgYrahivy8UWuLtQxoFPVb0phvi1loAAXtp
BOhxBu85WkGpxieYxXIz66uwLNhT2xGMheeHgaZ9rfgldEKO0y8DckU/PVR7DOqd
KSNbOjtAjtWfTMmhtAejNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAIpjOwV3
2h9Nb3xrGaNHUp3TS/fIZjzxPqM9HSVU4Zcspq7DzHYM4n75IoMM7UG5b/aZ0rWV
8+IMsXnDdmPPFPygAkIBerQtcjL12MIoKO7napz2mcGrizr7WlEYYlZyTChzRCsW
G9TloyLWO8ruKzAgoj5AjMKHnSN6HZfeRBjLDvOTfN4=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
