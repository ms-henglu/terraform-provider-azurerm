

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211029015226916047"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapntncqq1jbg"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEwMjkwMTUyMjZaFw0yMjA0MjcwMTUyMjZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQALv+7KzHnypulAEFf5d/4JYw+1rki
pz2Nj9jna7AyhhNaFIMcvMoL2xaV5+HNPWAivs26cssMfTqsqlPyqJl4+loAXZQP
kcHZs1oo2uPLlQCtKmuiMRGLzuS5eeJyfMr4HREckEcmY2JYWUaDXZxvnO/6zMhb
6ch+O9g/qfnSNdAOxlijNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAYNlvamA
3/w4YzRXNLzSwlsl5fEuLLJZq2VWJfZFMQS3e70ANbEO42e41eTvdAivEReSfw/9
iXDsTh5F8G8oyBIEAkIBjFdK2Km7cxAPhaR/AOYkz3JDsAwM4SgqFF2Un4zO/Zxm
dhwJbSBkDbnDzs4uMONjOljNP5TzpMRFQgAReYeq7UE=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
