

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220121044214921727"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapd33l6wl936"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAxMjEwNDQyMTRaFw0yMjA3MjAwNDQyMTRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBr0awUCK5LjLpfpPf+wjxo3uttO3D
b5zYL877ydX86R6Y725HRW/6cNy0tMZRSmecwQ3k5JOR0xM+M8O/S6NvwfQBCzpp
H+55jb+tkNhcP9Kp2JXwpaX0gXyHMeZAU5cQ8C69Ub5YJJ5a7qc3Qpm+o5aAvkHb
/DZoEFmq8z+LkKZR92+jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCASEs4A3s
09Ze7sWRYvnyswAH7qfsZjVO2zY6qcxJbeT+Dc+IVf1Q62bgbseMqoaVvqSaTX1R
m5r4094ZX+N9lFaGAkIA38aIf8OYk6pD8g5mN1v3jKHfqFUN0/Pstig93ekwSNwW
U8GTh1hdP/hgM5idZhN/TI0ozzW3laTZnKYZ16a2B+k=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
