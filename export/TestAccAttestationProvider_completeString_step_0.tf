

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220506005419813789"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap0whxicesly"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA1MDYwMDU0MTlaFw0yMjExMDIwMDU0MTlaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBCdRyUgisEOAE4XcAyBcks8TF1Q6t
D93TAla4qiML28JeAkviiZGIbwa+W0LbbzCgolYJh54rJvsCkB6ckccaLTUBwuh9
E1ubYVoM0FmUuAowmvaTO6q5FNbmuxs3T+4e7ngyjlLYtP+pQotokMb5IxcH2/IZ
yvemya8qPWOyZ4TndMajNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAPtxw5h0
Gc5RA93IKfMg5b6Xfp15nLMozWFmvqmZCcvwz4FrH0HzYxCQu5pm5e7BBvezp7Uu
cM6DuC2UTpUgS4d8AkIBOGganOwKjQf5EQk9JMMD0YVKHaVQ/7SM73vp+Fl49c2F
/O5nLFPF9H0Q+723lS5OJ2DxX4fX+BUd0Rj08alFkBQ=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
