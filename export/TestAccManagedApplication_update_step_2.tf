

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "test" {}

data "azurerm_role_definition" "test" {
  name = "Contributor"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mapp-220729032951105343"
  location = "West Europe"
}

resource "azurerm_managed_application_definition" "test" {
  name                = "acctestManagedAppDef220729032951105343"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  lock_level          = "ReadOnly"
  package_file_uri    = "https://github.com/Azure/azure-managedapp-samples/raw/master/Managed Application Sample Packages/201-managed-storage-account/managedstorage.zip"
  display_name        = "TestManagedAppDefinition"
  description         = "Test Managed App Definition"
  package_enabled     = true

  authorization {
    service_principal_id = data.azurerm_client_config.test.object_id
    role_definition_id   = split("/", data.azurerm_role_definition.test.id)[length(split("/", data.azurerm_role_definition.test.id)) - 1]
  }
}


resource "azurerm_marketplace_agreement" "test" {
  publisher = "cisco"
  offer     = "meraki-vmx"
  plan      = "meraki-vmx100"
}

resource "azurerm_managed_application" "test" {
  name                        = "acctestCompleteManagedApp220729032951105343"
  location                    = azurerm_resource_group.test.location
  resource_group_name         = azurerm_resource_group.test.name
  kind                        = "MarketPlace"
  managed_resource_group_name = "completeInfraGroup220729032951105343"

  plan {
    name      = azurerm_marketplace_agreement.test.plan
    product   = azurerm_marketplace_agreement.test.offer
    publisher = azurerm_marketplace_agreement.test.publisher
    version   = "1.0.44"
  }

  parameters = {
    baseUrl                     = ""
    location                    = azurerm_resource_group.test.location
    merakiAuthToken             = "f451adfb-d00b-4612-8799-b29294217d4a"
    subnetAddressPrefix         = "10.0.0.0/24"
    subnetName                  = "acctestSubnet"
    virtualMachineSize          = "Standard_DS12_v2"
    virtualNetworkAddressPrefix = "10.0.0.0/16"
    virtualNetworkName          = "acctestVnet"
    virtualNetworkNewOrExisting = "new"
    virtualNetworkResourceGroup = "acctestVnetRg"
    vmName                      = "acctestVM"
  }

  tags = {
    ENV = "Test"
  }
}
