terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.46.0"
    }
  }
}

provider "azurerm" {
  features {
  }
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

resource "azurerm_resource_group" "ikran-rg" {
  name     = "ikran-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "ikran-vnet" {
  name                = "ikran-vnet"
  address_space       = ["172.12.0.0/16"]
  location            = azurerm_resource_group.ikran.location
  resource_group_name = azurerm_resource_group.ikran.name
}

resource "azurerm_subnet" "ikran-subnet" {
  name                 = "ikran-subnet"
  resource_group_name  = azurerm_resource_group.ikran-rg.name
  virtual_network_name = azurerm_virtual_network.ikran-vnet.name
  address_prefixes     = ["172.12.1.0/24"]
}

resource "azurerm_network_security_group" "ikran-nsg" {
  name                = "ikran-nsg"
  location            = azurerm_resource_group.ikran-rg.location
  resource_group_name = azurerm_resource_group.ikran-rg.name

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

resource "azurerm_public_ip" "ikran-ip" {
  name                = "ikran-public-ip"
  location            = azurerm_resource_group.ikran-rg.location
  resource_group_name = azurerm_resource_group.ikran-rg.name
  allocation_method   = "Static"
}
resource "azurerm_network_interface" "ikran" {
  count               = 3
  name                = "ikran-nic-${count.index}"
  location            = azurerm_resource_group.ikran-rg.location
  resource_group_name = azurerm_resource_group.ikran-rg.name

  ip_configuration {
    name                          = "ikran-ipconfig"
    subnet_id                     = azurerm_subnet.ikran-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = count.index == 0 ? azurerm_public_ip.ikran-ip.id : null
  }
}

resource "azurerm_network_interface_security_group_association" "ikran" {
  count                     = 3
  network_interface_id      = azurerm_network_interface.ikran[count.index].id
  network_security_group_id = azurerm_network_security_group.ikran-nsg.id
}

resource "azurerm_linux_virtual_machine" "ikran" {
  count                 = 3
  name                  = "ikran-vm-${count.index}"
  location              = azurerm_resource_group.ikran-rg.location
  resource_group_name   = azurerm_resource_group.ikran-rg.name
  network_interface_ids = [azurerm_network_interface.ikran[count.index].id]
  size                  = "Standard_B1s"

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12"
    sku       = "12"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name                   = "ikran-vm-${count.index}"
  admin_username                  = "ikran"
  admin_password                  = "Password1234!" # Replace with secure password or use SSH key
  disable_password_authentication = false
}

