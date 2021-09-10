

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210910021107804091"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapb7p9ipwyl7"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTA5MTAwMjExMDdaFw0yMjAzMDkwMjExMDdaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAfQyb2n3aB+GDx4diOuL8j9hnoO9N
Q6vSHYjNZ6++X1Yyr19SgC5Ok5yrFHsxRt+frsiHfNTS4c2S+nzwxDRZRQoBqSbg
1jJq+x+vWCsZwW4wGtnbJa1UXDWMM76UGhk4WnJoQqEaLtMf90J6hGqpxSAeYiyE
NVIBqGePtM0iYVupkFKjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAR9hm4Vb
DYSlXm9wfwzAy8Nqv35/0UU63oz1urdXuuRuai7dHJnNTsXnlT0jm3cI1h3T+jSg
1p9sc8TVIA95uR9QAkIB0WIvyfekrSCG+x6UVDucb+kCLPkuQtleg5GUTLAq4mgI
9ZyHcwu9vSUAM7k4bpuSuDsXNbPdmC4uqAdDiHHFrQA=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
