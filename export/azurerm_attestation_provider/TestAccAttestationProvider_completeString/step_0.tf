
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230519074158904007"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapsap4kb1qvj"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA1MTkwNzQxNThaFw0yMzExMTUwNzQxNThaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAcOr5jfYuv2fOFgSt83XukkqabDs3
ALV6pXmhy4B2cbPumK/RqP5eCjnpIwS2DXRRwnuJsuPcP4zYnN05FZC7aNcADLXw
kLfHP3wUsthLRlu9KnsZ9+oWLCyxRTzcGnTOG7dNf6NG7gwTttmdsn/PfvDEbx4b
Pev4INKlqF9RZ6WQSnKjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAXBhcmMC
SO3+C4zwK70ezn4Zr0vI88ymueqcRFb2bGHQ2Gln7cwkh+r6b6exp5ZnTT5C2tC3
cNHf2zbmBUix2jfhAkELkcLW3RR4NsoAWJHe2soQ6QmLprJsNtnXejYCCWqtstAi
i5UHFGyS/eNIXQyDQxdP98W41kk6zBwjg3HAudlDVg==
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
    ]
  }
}
