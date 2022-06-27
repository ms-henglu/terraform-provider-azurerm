

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220627131558149892"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap7djojtmlgd"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA2MjcxMzE1NThaFw0yMjEyMjQxMzE1NThaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAhLzi1zlGiRgzmrH0LAgbEFzlpP/Q
mqSb1JkKR/dQZVzUSRw9kcSwRS4jNUwQ4BxPKPIGuCGrvltHZWBZIznw21EAk6Gi
0VE6QwJJZkc5UdHYZYKmwaHDp1Jhlu+/kjp1khONo4Lo60B3eyRjz6qsJGpEgM6g
D2v2uGri4kzuz6rkrcOjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAJ4hxS9Z
kVogTtmj+Ql+ElOHypvBcv2KlkPjPM6QkmUiwtSBLVx6/DtxdBDs4xAiDbVqpHF1
Ozz13cw5pGrAqTUjAkEIGzjCgWGnP3dVkiGNshJ02XLn+dUmwJlE4riWe83Hn9vO
z0No0rMhzwwPxiM5eyLCjz+Ds6wdfKYvH0JEtcHy3A==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
