
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230707005940325075"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapa2pwhy992n"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA3MDcwMDU5NDBaFw0yNDAxMDMwMDU5NDBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA8M+nRE7qd3vUtj80RYwPHseRU+pd
PL3Pglet0BAg2LQu+oiNWqeK+fNMcp4n526gbw9MYgAY2kL1yvhQllLgmKYA6XY9
xPGJn5DFqqCQu7II5+PzWxnAHGcVZU+A6gUN+FpoEERSrdScgw+pBoiScyGt5d4C
wOKtWl4MbbAtbu/nnMmjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCALeXEaEl
A1siTHVJ3c880KT6dUKSp+v8uaMLtmi6msOsE1/+60ROfl++yW3rypAPA02jWxXz
xXpRccc3jjWc726iAkIBpI9K4QaQrQPgCel/lmHPcOcF+//jwzyDFlD60fEaV/qR
qSaNFfusRptxNJpp/bVog53UtnoM3je4i2eSY9P7GME=
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
