
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230818023505385747"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapu6euxfzidc"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA4MTgwMjM1MDVaFw0yNDAyMTQwMjM1MDVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAUOINzc4ONbqhUmtHC2mBG1M+6qem
FDdrYbSQwd8nYoQul1SAaWcnf17tNgr296m5p1MsSzvZAFWuqmyu0KEF2cEAo68n
9iYOs9B9dMWkc6UlPNgaX3APGK/1Jw11SKxtrSus5TCEVMPPxmJOBxoBrIILQJFa
tAI1Uyzb7TxlHm1uzxyjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCATCMShW7
6TZu2vJk8RbEqe3pGIOKUhQ4EI0jtkeHpVx1NHahV8OM98/+GWD+CEid2pFeD962
Dzzc90OKMkU8Lwv0AkIB0yNCU5p9nC1RlpRgG7p8ntBBv+po4DyahHmokzD4dA0C
mRQOvxDY5kRLy//VsQF0wMmGAKbDnI6Yu9uLHSOC87Y=
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
