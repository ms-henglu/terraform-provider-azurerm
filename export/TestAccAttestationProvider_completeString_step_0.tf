

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220506015540287747"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapkce0loubaj"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA1MDYwMTU1NDBaFw0yMjExMDIwMTU1NDBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBjEvoxwYdmcJUvdmuiBY3zI4tAjVQ
mQHgWiusyPp1jaz9elv+J9CAK9ACaOVmmUSr7JWPix+mn0fpF4RfArEeCO0B0n/0
Vl0vUekBcOEKylLofegx1YKpnZyUnoIchqXVcM3NpNl+++ajTgJ4/cyfNpDKK/h5
Uq9qn+wFUoTbgIyeKHSjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBQsFIoHqb
UuVOq9b2ThEZ7iCGiuvJOCVAwi675HvQyQmFzlL0Jj6SpF5aGvIc0mGe9jmdseq2
/YeV904Z3608nQ8CQgDxHwMG8+wRy32lKViYG5WXrOOSNzIHDiZGg/gFbz9iSy/w
gLh8NsWt3+kFHnOJUgsmwZgwTCieFpG5T8U9bkr0uA==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
