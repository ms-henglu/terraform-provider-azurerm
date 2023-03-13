

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230313020727464104"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap9u6zvl0l2u"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzAzMTMwMjA3MjdaFw0yMzA5MDkwMjA3MjdaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBV8K9RoDg2Mkldd98g4MU7i8c/izo
avRz3qg8M45w+n4b/QMcsdVn27e2pnucy+1b8585aSISYDTTJldWzoMEHXkAhRz3
Nu6waqeevdb8hYhCx62PT5PtGeXQWGZu+yVHve6ztMHxiX3/ovJFAdDmgYjrlpBu
pN3ijWHNuul2//gWTVejNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBYC/JhxZ0
k9FckMtALMQ1eJVTrqKV7ulPz6Z0+qL/JVS3odTgjEhYke/O5tJ9SOgT6ASL8NJK
47GVMYktjfRqCL8CQgEqnfiXcc1yDoJvrFCkwVLwcrR4m14gIIYCIxk4gCyOF7Li
Vftew8JuF8ePkXoEYGswJRQE6EnfxN8h4tSZoZklfQ==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
