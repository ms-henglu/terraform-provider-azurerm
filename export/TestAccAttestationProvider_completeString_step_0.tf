

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220429065151358790"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapxvpm3gqpor"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA0MjkwNjUxNTFaFw0yMjEwMjYwNjUxNTFaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBzrdgQTt4QzKXsjv9AP8cjLdXciYm
P3x+nvf2Fh1XioQx581ZDdWpGVkhy23rPXdHwr6x6ovvnNV2rKUFXyqc7/MAq6Gz
zIgD0IoE69DNWrZqcYY4oPbSxXxbjY5TnohIkmJGh9JfZwujQJi+vv6sC3203RBT
tSd3QbrshrNDFT5W59ajNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBDDkI08Vj
3frReuRHkFgSC/AbfskfKpKN+d0jAMzQYt3wKoCAgqskn8ovdWBIHYUkffKHH85O
M/vWfw69dIbe7CMCQgEsCu1k9/E8NLSdwUiByCM8wmtjRJ2vDFYT47aRC9Rgcsx1
SZ3ibBsO/X60I0/NCvPCpwOjSKAO00fGKkSKYFMrrw==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
