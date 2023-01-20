

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230120051523165342"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapl3r2lua1bk"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzAxMjAwNTE1MjNaFw0yMzA3MTkwNTE1MjNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBxNpfQ3NiTYM6T3gv1ccNHz+nkR0z
rFtFwR1V7H7sWoshN8zN2RJWlOMRuRQUfNUQJqC4BrjHw/fv9Hrh6uAQo1IAYSIz
DqLilR9pu7i9Cg2h4HhEQybMn59udwMA2MWN4vjvhs885VVFyZyJrott8EEgeoHH
lnkka45NkYSCI2UgzAqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAKwVRrwl
8nDH0QmQQlZfFTT0OgUDfK5n1bqFiAfcMkvsI+lXx8oUWq6OSA6i7fZr/2Ar6irl
wywWbb4uxWLYJN6KAkEt4cJCY1Z8y0WSnQmzZNv9IDXppwRi0G3jinYqz1hkX/IQ
kTOa3SKFYmBP3lGzncmaerZuMb+IDze6nzmDymU+oQ==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
