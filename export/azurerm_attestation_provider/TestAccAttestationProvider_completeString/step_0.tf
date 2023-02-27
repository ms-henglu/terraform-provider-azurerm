

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230227175113677355"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapc9qmaqymq7"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzAyMjcxNzUxMTNaFw0yMzA4MjYxNzUxMTNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBAwcx1yqGgI7wdvVMuzGfAMBb0Xlg
5s9RVlKggB9zaluy7JqcQ8QR2HKY/TSsZ6mADFI6egOssas3Us+CX42RAn4APyeO
ubkWjFVXYcSqBq4UuLfl4xe90hjUSGEJ8NkXUf1XV6sYHiSNMp65fe0d4vjudkM4
8PRy8c0bqKWoVsN/p2CjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBSP6FmscL
NL5jv9aL++A7jzi64gRgxQqFapfhrm7WNPSRgce0fuOr4KdUyxVyZkXr0frhzs0E
x5p9W34ZkMReQgUCQgDEstyGa3A1zpvR1QDVa1Bvjw99JVQg6Q2caS7NuzJnf5MV
JDAKU+1fh605K9cyCM34jrvK0b3YW3NnVufCrUOuew==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
