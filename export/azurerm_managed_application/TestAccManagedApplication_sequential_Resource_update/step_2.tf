
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mapp-230120054826901760"
  location = "West Europe"
}

resource "azurerm_marketplace_agreement" "test" {
  publisher = "cisco"
  offer     = "cisco-meraki-vmx"
  plan      = "cisco-meraki-vmx"
}

resource "azurerm_managed_application" "test" {
  name                        = "acctestCompleteManagedApp230120054826901760"
  location                    = azurerm_resource_group.test.location
  resource_group_name         = azurerm_resource_group.test.name
  kind                        = "MarketPlace"
  managed_resource_group_name = "completeInfraGroup230120054826901760"

  plan {
    name      = azurerm_marketplace_agreement.test.plan
    product   = azurerm_marketplace_agreement.test.offer
    publisher = azurerm_marketplace_agreement.test.publisher
    version   = "15.37.1"
  }

  parameters = {
    zone                        = "0"
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
