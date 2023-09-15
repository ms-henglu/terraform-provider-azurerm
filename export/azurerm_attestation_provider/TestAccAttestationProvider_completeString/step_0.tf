
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230915022852777034"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap9ap4pz1c6z"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA5MTUwMjI4NTJaFw0yNDAzMTMwMjI4NTJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA91sNjwPWfA29IRSggO9q2GZczuMV
vREfZcKn1M/kFfn2hIEHPR6L9nK/nrCh1r8XVGte+iClasvLdnoQ8KowukUAnrfW
e5SimnBdyxKjWav53fUEqYSvga605YT/q/BB+y8L32Lsj6ikdiY7oGYkeL7lUZ/Z
zGDOwiAhrtaZtcAdg+ijNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAS4OpI2N
Wfnl2Tq8KrFpfz/IUBt5s394teUDQCgeUPpt1Z9MEVaATCDHy4vkZFRgE94I/5Ss
WyOjaLhQ1Cb9i8mTAkIB7nadtTFWip7RtpzyfpHYN0DlBqSpVk1KqzkNw6w4qRal
6dZsfx0ht+lIZVw1302/cvzsUNv0fs7IBuJ0NM927i8=
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
