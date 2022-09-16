

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220916011106805382"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap1gko261o2w"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA5MTYwMTExMDZaFw0yMzAzMTUwMTExMDZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBXb/w2klsOFDFa92xIDpDXCGrR0Tt
C/C7milPBzCtcgYOu9w97Zbrf68kAAP94WtCCBdFN/y1RdTY/UUCgR9rfJIBhn95
np1GiLDMM5wAKRchmBcafowU9rZqdd8lP+gZgL1bY3zy0F/6ViHaewlSQJtCE8UR
5kWoIvLK7nDUpS5N+4OjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAKspBC9s
noB1MDGNfmwQzA6I5oVTztfMKJHqNCFZmKay+OoCG/Gfe+X6qw43P/mrB1YbSxWo
Q+XlFAh0MzfXx/SSAkIBlDHcmo7keHPxyIm0YGJiFntTs4PcWukTn0dXBrtjDvJz
cJNa9zthIaXLHlfUrWxqUf6ZEueVMHhJfetUAO4bv08=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
