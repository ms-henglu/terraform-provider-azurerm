
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-240315122315713723"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap60oboajrwv"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yNDAzMTUxMjIzMTVaFw0yNDA5MTExMjIzMTVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAcAKr5+rpM1BsxS8bOSa8EaAgDDvn
HgvOBGH6D5nFLJZHmLSbu/OUwn+awYfdXUgM7lxvoYrn4O1OCvjp1J+1UCgAftrr
EV0BmOGOM3KGyEfU1fKrzlK5iR7HU4g5jSzffSPnAT3JstDI64wbJ7DAZhzjECnr
wXsYh+qEYTWS0U/bDNSjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAXLi8q1A
Umi5oZ+OC2qEtvsYnMoQgVDcW7BVjk1g/zNvwICppGkPHAWWY77v0pwyWuru5w+S
vRqLEs/6nW0yvFc1AkIB8QcAJGjE4GUktcWhsVxoQqOfWHRgbtFXe3a+DDL3Ihzd
7I+U7A2/I14iiTHen7DflXr7qcisQlldK/9hRxiV4zo=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }

  lifecycle {
    ignore_changes = [
      "open_enclave_policy_base64",
      "sgx_enclave_policy_base64",
      "tpm_policy_base64",
      "sev_snp_policy_base64",
    ]
  }
}
