
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240112224333467666"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240112224333467666"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "test" {
  name            = "acctestBlobStorage240112224333467666"
  data_factory_id = azurerm_data_factory.test.id
  sas_uri         = "https://storageaccountname.blob.core.windows.net/sascontainer/sasblob.txt?sv=2019-02-02&st=2019-04-29T22:18:26Z&se=2019-04-30T02:23:26Z&sr=b&sp=rw&sip=168.1.5.60-168.1.5.70&spr=https&sig=koLniLcK0tMLuMfYeuSQwB+BLnWibhPqnrINxaIRbvU<"
}
