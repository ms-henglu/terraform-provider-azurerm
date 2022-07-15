

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220715014150143382"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapm4ce7e6cbc"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA3MTUwMTQxNTBaFw0yMzAxMTEwMTQxNTBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAiOaeyqRpfAdnFcgspjWu8HU9wDoF
aLgu+FQnf2D00lruDOdrHKbSi10OUTR3q1zCaYhRGfz2n6wyysJ/gOmaBGYBqVB7
jy79lnemInqp55XTK9Mfz0TNHfdruZS0zULqXEuFDUcJ3/f9OykYTHMiCcY2jYq3
DqyOAklWhmdQo3UT/bKjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAZwWVu+j
rEyeSeKHz4oHzvs9PieWXgDHt3ZZnaHngZb3tdmODM6Fuvpj3LeERBeU4yTlc28v
G2vnTtl4cDNt9RpAAkIA3hMcgAgtJh2uyf6swnPJyKyPSdHranEFnbnKwKUS/Jlf
YQZFd5PTrQYbIA8r7EqaCaPQsw6ulpAyfgeHuCgBztM=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
