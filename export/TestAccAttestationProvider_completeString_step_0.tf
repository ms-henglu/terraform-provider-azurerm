

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211112020230878961"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap04mdd1as9n"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByjCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTExMTIwMjAyMzBaFw0yMjA1MTEwMjAyMzBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAglmbSKIsURkqehdG/pqXWUSj1iWo
L+bEmwz5bAfiWv0KwS/y+N5gymyaJ4C2BFZfv4X+s9apoASOO0jyFrCgHQgA3X76
DB0hB3IqUw4i45EBQ4kFK7edcx7bu3fcKJUDO/RwUNhmZbNm3qvigHNzTx4ID2JP
Z69XWsCMnNXsnpp2xiOjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GKADCBhgJBWdYF/M+Y
Srhg+Mcn6cDq02e+Dg6noNUz5d++j9lG+h7tL9naJaF4NRWcUXh/nDCgYS9iUgoD
ajiDDTD/5kKn6dwCQSxsPdNVV/Ld+YGfD9UcA/7K+GWk/rUIKIehQ4dNG6dgKDQF
aod7fEYwmGGU3HRrsTqLyWplDRRk8EXjAs8rRpLL
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
