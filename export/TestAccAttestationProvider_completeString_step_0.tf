

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220422024801297708"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap7vebmzk0hr"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA0MjIwMjQ4MDFaFw0yMjEwMTkwMjQ4MDFaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA8odJGId9KQPA0ks2Bq792RwqNug+
5Jlws1K6sWAyXhAh5EwwJCkDQJQ+GEl3am0pD7qKGmnIkxEQ7qgnebHTwv0BaJRC
0AXBFtNdtyBU/SKMvvEKUV2WxzOEbprICwsJchQOyMYCBTngx6Ye4xI6Te/EMPQf
+DhZmowh45PuAMUcjrGjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAIujpsxu
xz0PLVqtsK8Yj3CffvFL2agcEJb5qLMUvZyEuE9QumjTHDCz4sKx7b6IrHOFtwPR
N53btHBIAXWVNa+uAkIBJjoGlkw/0CXdZZWADwLG4ZW5LOLTtfJAMncG/7fEnenw
Ag5cVHcPmC0tjExhqYTH5mGFKskdqFEUYAV/PEjSqNQ=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
