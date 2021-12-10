

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211210034343353856"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestappfl9e8vgtg"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEyMTAwMzQzNDNaFw0yMjA2MDgwMzQzNDNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAhNXDKin+A3vd8gYR//D+has+oTQI
32CPV1b8oaiuYO7415LN4RpxExZPeS5bDnWekbSmYcRtx7kCvfGV2PSoUnoBpcT/
n1wk3qy0n1r0Ys0G8u8SHwdE3XJ45CW1+OjG5+TIJXBa+78L4QpFBJ49nyHDbmGq
Fio2nOP17+9PUQARL5ujNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBe7/HqzAV
ZKkWqaJE1WzEcVXNdu7T6S6zZCNkIVhqNfplnqIzcafF8L95MEvTfYR4hedAkVlu
CcX3Sz+CyPAD12wCQgCy2jcavEjvKj813YBbrleopsfxf4a0k55z/jOYj7qlSDR+
3+jojy/rXmSrco0S87YniPr/EjsIVC/qV4UapfSa4A==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
