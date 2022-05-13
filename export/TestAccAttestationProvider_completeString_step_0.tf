

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220513022911805747"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaprdmapbzbnq"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA1MTMwMjI5MTFaFw0yMjExMDkwMjI5MTFaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAdmPm22WJr7uuz0a1i/BKAW28IRLH
OoV2SCCwdkULxBxNtZn8606TxD9aRAhzsud00O0j7CQGjV3ckfd8CvaOtk8BL9/8
49Wlny9NZOa/xT6PXBTfrgm3nJ2evzFh/l8iK1Jsr7WFwA1n7k5RHF+1WmaI+ehE
hyGXPaNpWC0wgnlsQN6jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAVLuPSTy
Co3R5k3rHXq9GOf3bzB4zliXNrNfR8RHA9kncNNqpJETS7hPoJ85TlFIrlKFpVeL
MUaewPgLIByhgiymAkIBAKKEehjIDvxfTVP3aypAGpMsQjCBfTtiQJozJ0j0LWC7
biDEK43Qn8fJ3ec1JbKe5kYz4yZnWO3PvmCe46VO4C0=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
