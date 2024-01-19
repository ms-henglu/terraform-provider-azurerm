
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-240119024503482432"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap1zc810v848"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yNDAxMTkwMjQ1MDNaFw0yNDA3MTcwMjQ1MDNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBjc2VTkg7/8qHayh75ratYQQjsrQS
zqctzpyQ8px7mWImvPw3rCtmD+6toB1uJmAg09nie4IDTKQjLWQ2B00SskoBXZRK
3+Tliza02YF0yc5j+o1JGfQ4YGeo7q8RTx6hiqKH3SKYasaIFyJPYplEVnF69xZ1
uMgZp8sS65iL2oRCwfqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAfeOYb63
imRcRpGSGj9gndisHFLMR/gnLB7G03+xFzS+AAEJJM1V81iN7lyBW1w9+dcofcXN
KCM/mbZWmthSci6FAkIA6lyj5+UhP1NEmDiAFceTHkRxcu3IfKLGDDCvY2MvCJYL
o8E5fyp1sB65HRTkV27LtBEXOZL8ZS5D0s07T26r6po=
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
