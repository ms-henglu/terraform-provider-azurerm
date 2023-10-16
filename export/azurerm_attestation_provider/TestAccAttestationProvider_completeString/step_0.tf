
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-231016033356551836"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap0fb2mkn2af"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzEwMTYwMzMzNTZaFw0yNDA0MTMwMzMzNTZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBzGt7GEcBGFsqnOwfpx/Qx5fnyd93
oNYjg+GtDhNDEruMI5Xg9gRGczyqOPw/T5V487UHueN6DpkYWI0uXEBDDaoAXcNC
Jq1sCDy3zgsMfES6LqDg/UuSqGJWdomfCu5BDocrRoShCEquSMZZ8RWUqVcheyWC
YwRO8jPzJ4yUtKTBrhujNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAZhVo4V/
skNWCDtBsNL0IYWMW9eKophGfs9ggcJX54ZjaYsq67nHlDBQajt0PI4M4auM6OuU
CusdbcjR+q1295aTAkIBD0OugadmrETEbwPvqrx04RLaCDAnIjUe+N4/H9UfqdxS
vmIiMRsLxNjuXqT1lFb6J0Kv6hrFaa9wqdgtpmTK3Ig=
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
