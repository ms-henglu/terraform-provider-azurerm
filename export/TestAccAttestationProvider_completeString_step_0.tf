

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220623233245748898"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestappqw7m8senk"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA2MjMyMzMyNDVaFw0yMjEyMjAyMzMyNDVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB/a8RTK2pz04GDvdGVdfyhqrYSI95
GKH17HlGJJ4B0DwJ/1J05YsWcBE1amYKHXXVcKtJePNUFqw2s09qtpYsHrEAUlIP
VVVeAnONZavxz9LtwNZxibCjPQcfPBnHiq1qppjo1juff5gt5c2SrzDhNly4hBmw
pFKiz0qu2seNqrYQhB2jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAfSIOd3T
NBS/qsfBgm8blR+b903sB93wm/Sbz3W0gbwXdJgHKrVAqeGVPwty7To9EfKRPG7Z
0Ch5f4xU3vOTBWl2AkIBwf45X3gCymAgCCGJfD7sjRJZuGwN88qyk9BgiFb+KAo+
df5FzPNVxSIi/2dSQeUG1Jx07A5yUlxvl4RNyREDTSA=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
