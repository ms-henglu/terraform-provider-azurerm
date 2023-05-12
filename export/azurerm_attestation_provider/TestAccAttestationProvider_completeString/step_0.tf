
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230512010216803316"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapq1r0zei2i0"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA1MTIwMTAyMTZaFw0yMzExMDgwMTAyMTZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQARfqxvq/t/LDdQSrkl4RLo9k/wyoR
PeMhZ2VpH8WdRTkm77e+sgCU6RAOE5LHqkjdg9bPnVa0tMO2aMy85WJm90EB+kVe
CpReCh61KKMrYiSU8nDUMuiG+P2orj0T8AhxBeId5b8Cy1Cc46naSfMte9Cte4J+
RCG1Xgo+X3wt76ib5Q2jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBE4nzCAYn
BNaDQum2ccTy3VPLeyJ5qWOt8P9oaHcnnJs6IxH7b/nfIKcVvuZEXg4MqBEpvPYr
vOoyVeolRQ4FPE8CQgEINfmicwPXDioBSGSjPvnIwLxnP7Es4ITjJ4N7N3kyDnl+
4BHcJj4b3Ov8ubL3qN8olRXYRU7f1CRtE/UEx/JSdg==
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
