

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220408050911937878"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap4hekdfqwi6"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA0MDgwNTA5MTFaFw0yMjEwMDUwNTA5MTFaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBMkSjVpuIOZYi4k0cilDNAHdGJW++
PY7/258HcHM7aim15AYN+zoQ+NNm9Eeo93ZrXUP7XNvo4j5BOwuLbgMkmScAQCoI
c628suBU3RIptMr2EaoRSHducHfgaMog3Awy2kqTDIdpF34dDUSEfRx729o1HqFz
RKWHmUUr1zgA98S6osOjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAbzkEldd
bFIErIPvIlM1OssgVCD5b40iGwXFv7H1x4va48CpIhDHyWvjt1JAo0B/oWSidOLo
aVH51W0fz/4IZi5QAkIAsEh8luTSBjrrbiPMLvlDdqWgszAekANNR+J4ZR79/1Ib
GGMIhkwjpR9WtOPqCtm98rTN6XKaxktawC3lDEMut2o=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
