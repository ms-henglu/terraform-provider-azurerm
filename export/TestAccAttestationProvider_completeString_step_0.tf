

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220722051606545410"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapkkewv87ztc"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA3MjIwNTE2MDZaFw0yMzAxMTgwNTE2MDZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA+vKfH+JdPMU3LecfTzpcHnT36Dcx
NQ3aEMG0byK23E2gNWSlkcL5tcGrd2sARy8/x5KRD/PHN6CCNwf7N8DbtSgAieEa
eKsM5XzM0ieg9+lsNMlb86DHSmv/BCJLUKV9zpahYg+bTIFcAEyvZOMYBMAfORN2
kkZMS83qmrUAXfCeeiqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAL8EeCIu
yrKUoD2un1lBCK3Oal2pgrE7LGFwNdgtbMh8K7UOY6eenZ2eDdMVV9/auXxmfh1G
ZFfJG9H85phec/1rAkFAqGDm9G1VDC3VmG9yrKr+w6GBRiI13wMcMMsZLf3sD7Pl
Nd1xovsJJmwuogfbdFoptqvb/AM7pxRwG/SAXkoQrg==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
