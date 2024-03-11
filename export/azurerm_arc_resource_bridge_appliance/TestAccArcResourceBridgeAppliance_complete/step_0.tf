


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-240311031328451511"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-240311031328451511"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  public_key_base64       = "MIICCgKCAgEA1h/G5eXFmvcesQ8tmvQDYQqZoI9Bmk2PggjknsAXI+rPqt3xJayWgWnKNicIbPOjD69Pq1hFeiwdHAqcwxU9q/U0QmSa7oef1ctmJ47SlHOmYUgSV/3ArtG9up/55ZJWuPe+B2mDPxOuo/csuxx0YQqYDNCtlCAxHPTp0pakUwZ/E0vmkRNyd5HneJnqu/JNq7uyaDsQVxAp7LwSDw5bOfQ6ctkcmZWGwd1JQSZp1D5JBENTHfDr4ykUIgWMq8Ztph3fRo9PkBaTlX7gaV12XbmBDlfTq1Y4+nXPlBAdbyZi6wXrYdHVmpGUZnu5sLEtV2pizDzqTJkx99L0HsP5TAE1QT4yw+jP+S54AEToB9XCdWoFd1arrvQ7mUDZhS4M6Biun6KcS3adY0OBoZakbUN1XdNfq91Rj0QgVdsLa7IaBFWfg0F5ddBRJakGYD+SzuQBKE5rhLSvhXt0s7nZw9cSITaD5SrPqt/TNy2MTv26AlQGLutqq0N5HMSMRhcMmw+adOlpMaafD8jCAbB+t5Ot6pYZAG1J2dzqjx+FiWLrzdthYxtcAmW2dnkrBORB0/riFjQxnYrM6uEfEWDRk2DIRzZSyERb0ZlaAIC1qFC37gv9i6MuTn7eLgXEHmfVUOPkqecC1ABGGrde6LeH+T9SFsHJWuaCfRzQqP/CTP8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "hello" = "world"
  }
}
