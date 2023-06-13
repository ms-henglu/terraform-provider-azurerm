
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230613071322073354"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestape8abgdbadd"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByjCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA2MTMwNzEzMjJaFw0yMzEyMTAwNzEzMjJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA43NKnhUO+UstHOH52JHzo+vWrKVB
f0kSE2w0y74s1XJDjybzzXnykfhn/ILrNe2clwq+43wKYwOuBwpkhdjmKmsAnKos
0Ah/rc9kAXcfVMzfGUk0zDNSAH9pSkKVNiu7bfgS9NiFRO/I8iHnEyy5/jq111AB
zwgfXRQKv0oA0cUV6vKjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GKADCBhgJBadaO7rKI
aU0Bfq4xNabvmiNDfO/Tn0tjk9fpyHJnSa64kdtfxx70d04aWOKeNir6FkiL2/dF
cdKyqr1STTOc7+QCQQf+PUB4kCTG1ZACidb80LYJSY8QjsHTzUJAET4euWj8Of/b
VbulA7DurVfAaJ0/gbuTLKtGBA6jxsKteYncC7O3
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
