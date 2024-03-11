
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-240311031343119357"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap4gtcmijbbq"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yNDAzMTEwMzEzNDNaFw0yNDA5MDcwMzEzNDNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB3qgaJbs6LMlpVCGigLNuNgcDOE7R
QyH/QpmRk3w36C+YZwt7YFNIIbzWwL7NDaq8i81Tg/7rdNBlp6viMzX+r8oBq2Za
OVxNrbhQ1ZwEqqcvIOK7JJ77UIDQ0hJmoVdRKiXcyZhI1ThJOwsDVTluh7ouK+Gm
ZAlujV7n/OWrgBJrB5GjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAdEqNk7k
HsJsXPiW5dU5ZMAuzDn338pu0nVR3uDapl7njwGO2nAh0gKL+M4O6jW3rhkWv4gY
YF7JB67c0CxK6bQzAkIBwNpFFcbwI0D2n+CZqjlIPVYYOctqbHNecqf2aGXxrElk
Z+9c1L7YeAw2J/W/n5OwydVtqta9sTxoVidiuulPwaU=
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
