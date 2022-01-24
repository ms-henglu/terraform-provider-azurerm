

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220124124725950823"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapeg0tntuc78"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAxMjQxMjQ3MjVaFw0yMjA3MjMxMjQ3MjVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAsDvre0951BICvmubm3JzTAxdtau5
aGRt+7tdJgeU3RGsy7hk5vOvhwO/zvA5XROQpl8amrn56ngX46k33Ebl5zcAF8qg
esgkohzy1QFaNf1K/tr/2spqF6LDxQ1BP4SYrC+Xx0kB402IU4pen9YLu/++R35X
FLUwQwfWM7OgzDZQ85mjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAdijjsZi
MycoAHM7gfIb7lQVc/ni98StaOxhrvwult9MO7x1GXZiyb+aW/Wmf1dZi96NdugJ
Ml+Bj5NdVEGHnYwQAkIB4GGsOfgJG/Wa6/8sFzL/HrHoOV/a5ycaNmkydhJJINDB
YIJKFAGVYZ4MTQggyL+J2dn916WZUG17pewUzW4rtCk=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
