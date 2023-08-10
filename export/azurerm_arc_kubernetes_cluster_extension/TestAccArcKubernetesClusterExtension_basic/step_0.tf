

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142925128807"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230810142925128807"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-230810142925128807"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230810142925128807"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }
}

resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.test.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctestVM-230810142925128807"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3919!"
  provision_vm_agent              = false
  allow_extension_operations      = false
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-230810142925128807"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1hA4JReZpTFWXprKT3dyZBeO2bwB3nuMVA6kqAfyfrIocYqB3mPS3UgFjoOT8m4hjVfvVzsCdmGG7COW9i14zpv87xUacH/AQsFgITb4I76fvMb99iKKSjCy2M5aE+t85LKTXt7djCvHh/qVLXueVVJ+BHYxTn501Swyi2VM2MIHMYSc6nJlIgmtePsA5GfYV8g71gHHh5jpOyL26DEagArQ4FGAhQ5kvdnxab33opznwKzf6IEsr0II9n+DkhfIF4/VQzXgAy7hnZ4l19vKGWzJZ+ec1TDtaJXsc8a+SNlGwsDgxyiipouV02olBBxWeMUsXWGZfSj4ts4k5QTQWMbXPvH89wikFzRrB/gzrlh59A8HD+99uepRDGgH9s5XM7A70BZB1flgsY80ALA1Lr7jiK6YgDEKXpXbFBTWZLDbLpp1lxoTvtTwJADVtFIBovkD3E4cYQcY46LtVubDIfc5GrkcdUp2XfyxMTXMeCPozdYVBCBaqgu0i/8mFdfSswNKeB0qqDcgpB9ErfQ1UfwVqYxRfGeEouGPPrhW4WcwgaEneINlp24jqxrA9WlRPvdY3TFxQd/y762Vmw5074/5mLs7M0qes3yZVfbj8bA7sZtdfJy0GhOBFfbKAP3pX9y+mZLfSa6vhN526EoZJ3N3AB1hrdco0TjeeKOwStUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3919!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230810142925128807"
    location            = azurerm_resource_group.test.location
    tenant_id           = "ARM_TENANT_ID"
    working_dir         = "/home/adminuser"
  })
  destination = "/home/adminuser/install_agent.sh"
}

provisioner "file" {
  source      = "testdata/install_agent.py"
  destination = "/home/adminuser/install_agent.py"
}

provisioner "file" {
  source      = "testdata/kind.yaml"
  destination = "/home/adminuser/kind.yaml"
}

provisioner "file" {
  content     = <<EOT
-----BEGIN RSA PRIVATE KEY-----
MIIJKAIBAAKCAgEA1hA4JReZpTFWXprKT3dyZBeO2bwB3nuMVA6kqAfyfrIocYqB
3mPS3UgFjoOT8m4hjVfvVzsCdmGG7COW9i14zpv87xUacH/AQsFgITb4I76fvMb9
9iKKSjCy2M5aE+t85LKTXt7djCvHh/qVLXueVVJ+BHYxTn501Swyi2VM2MIHMYSc
6nJlIgmtePsA5GfYV8g71gHHh5jpOyL26DEagArQ4FGAhQ5kvdnxab33opznwKzf
6IEsr0II9n+DkhfIF4/VQzXgAy7hnZ4l19vKGWzJZ+ec1TDtaJXsc8a+SNlGwsDg
xyiipouV02olBBxWeMUsXWGZfSj4ts4k5QTQWMbXPvH89wikFzRrB/gzrlh59A8H
D+99uepRDGgH9s5XM7A70BZB1flgsY80ALA1Lr7jiK6YgDEKXpXbFBTWZLDbLpp1
lxoTvtTwJADVtFIBovkD3E4cYQcY46LtVubDIfc5GrkcdUp2XfyxMTXMeCPozdYV
BCBaqgu0i/8mFdfSswNKeB0qqDcgpB9ErfQ1UfwVqYxRfGeEouGPPrhW4WcwgaEn
eINlp24jqxrA9WlRPvdY3TFxQd/y762Vmw5074/5mLs7M0qes3yZVfbj8bA7sZtd
fJy0GhOBFfbKAP3pX9y+mZLfSa6vhN526EoZJ3N3AB1hrdco0TjeeKOwStUCAwEA
AQKCAgEAuVYVplfGmXYcF5DhdOgwTGTxM6dJ3v0NRIHhIfKvi+5ogdWwF4JKQXho
Bzn40D92IVBvUxEuUpyiGrW9sKsyG4CG/+E/oQOazLFsr5VORnR3DRUlMQQ6w31i
e8A90V1kJwZN/ifrnb8R5LOakWSkc68WmHpUumdWdHLt2C7+1/U2ETOGQJ6G3W+P
mF2KKjeW4nnlBKdJwCcuWBsvt108WnwC2RT3tzv9ETsvf6QQUeST6whCXKXqsFr2
M6W3nrekcHIB7U0qBNeEU9lnXntXgafkwWeRLCxOgOy9aog6nAwy7c/dTdHq8VON
hxwxrFt0qt/cR4WHRQxCOtREsVz3nTAAuGa1VjLonVl5FMmLmJDWB0vyEsKtM9vZ
8tSoHzVfCachhZmgC6Et+v/trSmYRZyYRZ3LPghWCVKveQbSzggHPqbk72hxewxN
pz2Esbrt4//S2rR2Vcfqz7SG2Z1ZKMsAkfR67ye5nIYOveiGjs1Oss6qA1+kgt3b
zarWXWx3F+Mot3CIWV3SGZ9ti7wJXQWcBZsO16hTl6WUxiFjSwO6XCTMULMdb/HF
KePzQdZMKRofoFJ773p1mamTiIFDcnf7ohnS0IOXY169PprbBWsM7q8vhpLjMn13
HpgHeJdhp5gIW0fL5VjUXneZs3k6YOoAmcYCxj7amHOuCWUbfAkCggEBAPJLNLW3
OM8rEoeR7UMiy8TRtHu9BuehDOs8l81zkZKKKHXML7q9WIPPtGp4JH29Gsd8nDZS
se5Ief3S0HDP4BWC1Z6yf0ub4wLa4fAAW8AIDddqZ3UzdgO4A2MKcA8nB6ZIfeYp
9so6eOGAbfFWtgUn60bsGyjr3r4ERLHpUBelySvNBEczfMeS2GP55KPMceYXo8Hm
FdueVSbP3pBkkbJkdpKK15TuMQkB6n89gQcToxswPAEt03XZzNH1NUNaia0CBPrK
57HXrSj7ZX5orXr8y+k9oGFiZgzlwGii2aTR+pWBB5MdXvXXhGTy4L+23nAlcwF7
DzHLrHld1GLZaPsCggEBAOIsMVOytp3jrCf/AEHWMnCnNcayoVKTOUSRtr3rbP70
q2i6smq9zza9KDZMlHTIqN1u+wYrUGfcYwsKJsF8vxVDHNn/rt5M0eDAczzJQhX6
fV17tEi/ub6ubtRl9ultY3eiebyXr3C4LkTDnfo5JI5PjUYczPNkECro5uA3vsyL
RwrSJHhixeC1XZF7XyE7HQitnpq6uJ38VrF/LRerzS37lmhdUH3Kx2H6S4ZwXL6l
9PtZVdyNmA4gu7UQie/mfPiDp4rRbflF5aAoqE+UoTOn8EwyQoboihwOkgrT21mW
KNd1yd7hW6CXJUNGo5zD2n5vRBSnFeP5A9/78vxEcm8CggEAWnLKtX81XNj2bNeD
28kUil/CYWLaPgO3/+S5wn9++1ZJ7leQBcUDUwlpj0lUTgAXDBsvcXQDajFyINfe
6g4f18fkmP6HWKFT6E/vghmQJqqbCCx3fJ/+UTsTQJi35mAqkd+D6DUIJMwZLg00
faBiCKCzSuF+7hLHLuYHAudW98zywUAidbX5wcLGtuOlf6QlbMCsaAjNZhPAM+Hr
crmoThEE1oWwHq+gbH1jnaZHEW46OD8UV1hVFSx+Mm64OHGG7afQVhMC1TfvM1pN
tBe9kyjlsidIRLJn6C6oWidY2hds1Py66CdRuLKAgPLOBaNtfC3utcHLlUo0E4Z8
b347mwKCAQAgOBtuyO6q31wO9oya1GCrG6bVf2zrzn1B/2AA/iCw0Tn52V7BRfjW
22t3EMG1QUCNCtpHrrPtl7+kOvX6akLuTHk3tOy8TkU3tzKzXhhD+UMSpiSwmF9l
goPXTg82gZbB3CtralBbxmEQ+qzukGVcwIhnjILFyWNkOXlqR4aurMiaCgWYALof
oLaLmv+aREmGivUlJaRXHTNcZbmOvbKk8koi4+grg0+T7YwEwszze8DCbZ+Fo8Yd
fRxAVvLPcg4reNXNOLhp4kMr5Z7Ud1/fc/UPZbmEbmv+QzUaxcNhp7p5txXi4kej
QOTWCKIWGvBtQnx4VLURnM+ogMPEnBuRAoIBAEYlkpQiSnldvIe8xvQg6JjSkUv+
sLi/XxWOEPkkb4y6D+9v/3dH3DHmFLYL9aCeaWyR73W6ZevmKGxhtRTSABsTKNYf
siVNwa4/s77k/aO/ITU+9m6vu4ku6/5AaquOERCyrdB9Abj78fP7YNHszw9C8k5R
uQ4VXn4qFYkEi+sRxvtOFXycYwWarZIBOpd89vhCAEIkWU1KWZEQLWKDRvcj6uNY
mTep3C6Xns/PPscKdpPhFT08AYnKlwLlLfvzVc/tyXgRMRaVxmbAOQg752lVj5EW
79sDZNhX39WzcmkInvWc9fidVxuZo8pBRWEtQsEBvRlir56zJB9xv0epcOw=
-----END RSA PRIVATE KEY-----

EOT
  destination = "/home/adminuser/private.pem"
}

provisioner "remote-exec" {
  inline = [
    "sudo sed -i 's/\r$//' /home/adminuser/install_agent.sh",
    "sudo chmod +x /home/adminuser/install_agent.sh",
    "bash /home/adminuser/install_agent.sh > /home/adminuser/agent_log",
  ]
}


  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "test" {
  name           = "acctest-kce-230810142925128807"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
