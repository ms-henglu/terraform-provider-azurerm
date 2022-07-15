

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220715004133756103"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapzk4xohhza6"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA3MTUwMDQxMzNaFw0yMzAxMTEwMDQxMzNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBpqX34R9Mof9U8Lnh+39PIG9+srJr
Th00DDQ4rpzLrLg+3d/njPtSL/WyDC7rBqD3bsRynJHGmeONdmTZ/KtZHQABM1XJ
twimtXsyQRjfgq9fqQSrPwbcjAeirlUbiCV3bpQcVApn0W2fz8Ge2L7ysRYYyxnH
eoH7d5mj4voTCSikLCejNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAa28onnp
ycHlA/Aju3bV1qYKSdK1wxxN4T31jYkaiPT4w0cVLUqsnexjBNvKNfaYzJf6d3Q6
aE152QbWjksmjtqiAkIBmJ0IkQAuGncfJXz8pq6R3GEHWKTpfZaD7yuH+4g15Vs3
VTwS0vZeSc9F42eIa3HU3PaDJfb/ktqao7owbW2f54A=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
