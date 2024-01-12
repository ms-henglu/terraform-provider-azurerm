
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-240112033840055790"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapsyy6666evs"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yNDAxMTIwMzM4NDBaFw0yNDA3MTAwMzM4NDBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAZ7nIQgVxbUyz4hGED3d5IrwfYn7z
z1vFVdB/vzeDs8BTgan4IE/tuUlSqoFyryU4Ij+kpuj5U6kyvjATsVcAu2IAG0Py
mkvk64+UIdYSX1nqMVhXTugvGADAlM6gJRA3bvvZvOz4BuveH/QK/YfaddgmSZyP
DDKszF+aajN9BDTcHayjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAaJaYn56
cqOJt/C3j56rhujZQ+g2Nvyq1SBQX2yGS4khacHwuZzY29x5dGCAQ9UEs6PV+8qf
zlu0IpLh2bOixvRuAkFRgaegWx23EU6QhAlbvgJSMpA9FJicWY4SG0SGGduAylL3
FYH3rTP6NQugORT9YXHOj2FYNQiS6pjxsSgELaGWQw==
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
