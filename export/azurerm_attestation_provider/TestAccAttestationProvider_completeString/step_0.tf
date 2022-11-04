

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221104005115619666"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapc0bxgrkv1b"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjExMDQwMDUxMTVaFw0yMzA1MDMwMDUxMTVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA7Rdd+W/q2qbeQxMjAr8lnj6YRWEJ
24OobCm3Ye9+3wLLZgjL4mocfPhXcDFC9ImxW/h2Tx9YhmuaZfLYszqfBi4B1WWQ
eRE1d2LD+UAa6Q4nTAoWACpxfdsEH7f0JphyhlFGkXUWwkHA34P4uv+eN7qHYO/k
4irCBwoPbWWEm7cVr7ajNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBGBz5LJ08
XEHYVJRbMLh2UTTHXqudW9xghIm331kYEiFfzdAboESoTPS1mKfUuqFdsJtSJkBn
C37ysscKPMIylhYCQgDkZiEwhd/STnpyll7R6gSQFsk54s5AOjZEit7UERmf1wIF
UiYFHxZibRjBsV1l8yXZCCeYxI44LUrhr23zgyyHoA==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
