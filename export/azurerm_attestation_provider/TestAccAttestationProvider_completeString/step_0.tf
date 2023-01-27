

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230127045002117997"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapsamdw3krme"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzAxMjcwNDUwMDJaFw0yMzA3MjYwNDUwMDJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB+h6pZFyj9ZnBZGrbQ4MXyLTKHdO9
hNsQ8Bz51PwD0W6BXygXh9ylkuP/ODKMAcCL85igVv4kDf4DW/thSXQQC/YA3RM0
QaWnDZBuh3xKS9ehz7Wd2/dSlmS6kItt6NP6uccPxwPh4e9HG2P7uBmrebEbZjeM
S3C18sQ2A3VwgSlIukyjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAe1njAUt
J6oyOeVYS1sCr59L0wsFaKSp+NlWyv3MZ9LQMvMPl6GZ05WY73PJ8L/qSp7AFrtP
xUo8lKo4w2WBPrlfAkIB1MVZlTWc0AlSc0pUHQj5Tjk2ocxbrwj8CTsWUUlnGu0s
4MTfs4jnHR0RRvmdVszgKf2lAABoqN6iIxRCLX6Onws=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
