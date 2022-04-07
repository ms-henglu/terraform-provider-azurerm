

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220407230659631076"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap2iq0uc1svp"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA0MDcyMzA2NTlaFw0yMjEwMDQyMzA2NTlaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA7W69kpSV7xs6nLP9TosgSjL8plvw
fbdZSFsSaJ3aBI7VAgIt2v/Ug7MkuZIWATfDB5AVbKjufuDYBTvSTWsIKhQB/81N
HrOhUDpC7WibiRilZ4t+Y9j68t/oAnubAFufUeIT/jf1sllQU13ep466QVKXxf6D
yPjWRaIcOVeeTwOwsd6jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAK6L/zTn
vOMjFTOEDx8umbhpwAWEE8ZZ4tBGc8IhCH4OWi6rqwa63e2Sb5Q7agwTHflp8jSH
j0g8BMY2RE68YLFnAkIAyVV4Eme9mf0nTGaQ7rG/UaJeL5gQ644eBLZz+Xccyfld
jji1cQ1dzvdPByJKMkNHhY5mU5kr44TJb4lPM7js6Ss=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
