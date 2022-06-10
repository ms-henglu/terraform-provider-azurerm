

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220610092319594572"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapnheopp827t"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByjCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA2MTAwOTIzMTlaFw0yMjEyMDcwOTIzMTlaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBlPOxrV6m09nm4keH+3PcTLPuJSZ7
nwkRBqG8tcSjEq4Tpz6PmvJ7s1wGgqld3HsUCtiW5Res5NZwsxKIx7nSbtAAodBX
qvQ+nyfY1SA+FTT1usTosSHh/lRPcEy4Gi8B4NhcMlsyAHchcBRJ3eLplhj3ehEw
DS5Yu2QMMvtdmBXO4WijNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GKADCBhgJBJSCPEZfN
t6oxImoH4SvgNfcKkKwsNyuRzhpunIosvKg7A0C6Kk443UugRH/63S0c+Eg4uj6b
yKFXKZSlAvXEw/wCQXmf47My7sGV0CrtKYau/rjKJcUaquh2xfMDFbJxpny5IIZ2
lFiJOUT92K+GE81ojqFJLdgtSt7p/WQLfFr6KErU
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
