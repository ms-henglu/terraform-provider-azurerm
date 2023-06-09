
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230609090819805634"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaphcmfehxzfp"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA2MDkwOTA4MTlaFw0yMzEyMDYwOTA4MTlaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQATr+Qcwe/hkpA9vYS1rn9yJrBJ/kC
5N3wdes9q/Uf9OiM+9ITDM6N208OmHeAgRLgm5YgYWx5Q5/A87+Ly6PDM/8A3KGI
HhBycHk4gXa78ZLrvchmQm/I7Xz3xcA4Y3wl4RM7Qt8pZKw/vFzd4Y+y3t8/09FE
X6zQUYGp2gfMgpBpFZyjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCANaF3Zb5
kuSd3g4VvjLgSpD0maVApNuDAj6HTfFPZi9aMil+CtZQXhPSLX1XIXRBdUIxtapc
3xHvVcv8RWn6BZFQAkFZkYuJL2HT53n4EcnI04js6PuU07uCZlYj4xejoYRHZn5J
q+usOeyLSMQgPeX+LPFe37w23A1WYduKVp7McfuNlQ==
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
