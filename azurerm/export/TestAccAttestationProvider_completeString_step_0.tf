

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220627134230319251"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaprstvhb09uf"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA2MjcxMzQyMzBaFw0yMjEyMjQxMzQyMzBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB6BX/TDG1Vrd8sKF+nBXo3DWWaYSi
VTR3a5VmGPqvsJJ5JpTNdAW+Jl+v+cyfHgSEDaacuj/q68+1eY3CveO7PgwBMG0y
4/ZOp24SylOV63/iisCL7XSbpYUsDEdHU4i5t7hXHGYociOsXW91e6FfSj+XrX5c
jHr6SdaYS3lr8J/jnlOjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAV5fTBsW
HP5G75IcYLvSshheKNQPu+6cK4XnChd1p0ZYcb6subW+JUOMhfNEdjwvXHwquH8w
SeC4TzlI2sQYn113AkIAl0tivQZMer4p84YBh//ilZhsBa5m+zfCSr2QeprtwyAG
4mjkyqmB+UgSn02p+DXHd3T/z6zP1ENTO+yAL0CKCjM=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
