

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220128082105444315"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapgleienwpd1"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAxMjgwODIxMDVaFw0yMjA3MjcwODIxMDVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBa+es/e1B9TyP4+Q7f2cGfNShsIsU
fXNpwBpyb6Pi/9+0aV6Dcj5lvJ5/o0QmKO+38D0I1H9xPf7imOONr1uNYTAA7Xiv
QswzElVB9EXqYTtoxCbzzCzA48yQmTAs+MFftjA+fpdyXACS720eJvAg1xL9xGVN
RsaIElaW8FOuTHj3yAOjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBUrcy4xBs
PtQQ/2TwTCksXPm4uSxxOlFdWBGZGzJZV8cxj00Mp+EJ1+kirQjglzFIA5IT1HKE
iB1Ipsj2njI4YEcCQgGlY3JXfzqKmK9JMfsVnDBZDSlEpiLSyDa0n9hd9Qrk7k61
FTZ7oeJh5tdE0/W4JFyYJz4lugPa0tJAOCiOaOgwKA==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
