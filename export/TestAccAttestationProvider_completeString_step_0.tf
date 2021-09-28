

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210928055142033264"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapbtfg7kzpbl"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTA5MjgwNTUxNDJaFw0yMjAzMjcwNTUxNDJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB79skA/D4LSgcnq59i18wQqtILTIM
nl4BXzWdm3IrQic5eNATgGzVdbUcQ95Zm2HiI46KHzgHhtsKAbKOSQGY/foBWGSh
L1wXVipq6TcC0/P/wznpSUSWr3FuwhHk9t3Co3yLQzO5Cs+TTIuLkExnbIdWXHuE
gA+V8+/JbNBtaWRjXumjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCARYEpKdO
5gFZQDEqwRjONb+IcallxntzNA6vbhlJOzuoCSp8dUKsiCGPUg7deTItCGLku4jC
GadesebeMbRT6wYZAkE1ygR6OUI86lbDJNojHjEMpjWfqve1tGMwlghHs4ItL0P4
7pCa5hN0OCtsiGP30zmHCQ1jv7U5iCdTO4h2ufpkYQ==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
