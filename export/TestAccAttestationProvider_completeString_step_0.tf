

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220107033538180950"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapsyaqe74r69"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAxMDcwMzM1MzhaFw0yMjA3MDYwMzM1MzhaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAXV+epb1+k+0b3hO5g3oLIchzDtix
BIeS1OP/6IVOUp27CupfCJhk3rfdDc9sIHpnSyMOsCXwjd9/m6s468frPIABF1mD
D+1v8DX+izLTU1PsT5wPOY/eWFa6myf87Fk3N7HXlGmBgYu0r7RYFwG42089Phpo
MiCeU1Q6euC+zh1KyomjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAel0QWhd
1qOt8U+TYyDL1V1tQTJ2rQKUFkSPHdpJFiSYBXAM1qUrd+q3jVkV3BQAMXiiFAEu
ZAo9XnXWRFf8zfXrAkIBhXo2879e5CqnESVYKh/NlxIgS9av7oetDYLuWIbXcHQX
kzKX2fXxjlFptZ5M71M8SzMd0A7Px2PIwIDa91YMjso=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
