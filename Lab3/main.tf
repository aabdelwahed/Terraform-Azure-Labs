# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = "b15xxx-xxxxx-xxxx-xxxxxx-xxxxxxxxx" # Replace with your subscription ID
  tenant_id       = "061xxx-xxxxx-xxxx-xxxxxx-xxxxxxxxx" # Replace with your tenant ID
}

# Create a Resource Group
resource "azurerm_resource_group" "linux_rg" {
  name     = "LinuxRG"
  location = "East US"
}

# Create a Virtual Network
resource "azurerm_virtual_network" "linux_vnet" {
  name                = "LinuxVNet"
  location            = azurerm_resource_group.linux_rg.location
  resource_group_name = azurerm_resource_group.linux_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_network_security_group" "linux_nsg" {
  name                = "LinuxNSG"
  location            = azurerm_resource_group.linux_rg.location
  resource_group_name = azurerm_resource_group.linux_rg.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a Subnet
resource "azurerm_subnet" "linux_subnet" {
  name                 = "LinuxSubnet"
  resource_group_name  = azurerm_resource_group.linux_rg.name
  virtual_network_name = azurerm_virtual_network.linux_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Associate the Subnet with the Network Security Group
resource "azurerm_subnet_network_security_group_association" "linux_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.linux_subnet.id
  network_security_group_id = azurerm_network_security_group.linux_nsg.id
}

# Create Public IPs for the VMs
resource "azurerm_public_ip" "linux_public_ip" {
  count               = 5
  name                = "LinuxPublicIP-${count.index + 1}"
  location            = azurerm_resource_group.linux_rg.location
  resource_group_name = azurerm_resource_group.linux_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create Network Interfaces for the VMs
resource "azurerm_network_interface" "linux_nic" {
  count               = 5
  name                = "LinuxNIC-${count.index + 1}"
  location            = azurerm_resource_group.linux_rg.location
  resource_group_name = azurerm_resource_group.linux_rg.name

  ip_configuration {
    name                          = "LinuxIPConfig"
    subnet_id                     = azurerm_subnet.linux_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.${count.index + 5}"
    public_ip_address_id          = azurerm_public_ip.linux_public_ip[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  count                     = 5
  network_interface_id      = azurerm_network_interface.linux_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.linux_nsg.id
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  count               = 5
  name                = "DebianVM-${count.index + 1}"
  location            = azurerm_resource_group.linux_rg.location
  resource_group_name = azurerm_resource_group.linux_rg.name
  size                = "Standard_B1ls"

  admin_username = "azureuser"
  admin_password = "SecurePassword123!"

  network_interface_ids = [
    azurerm_network_interface.linux_nic[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11-backports-gen2"
    version   = "latest"
  }

  disable_password_authentication = false

  custom_data = base64encode(<<EOT
#cloud-config
package_update: true
packages:
- apache2
- ufw
runcmd:
- ufw allow 80/tcp 
- ufw --force enable
- echo "<h1>Welcome to $(hostname)</h1>" > /var/www/html/index.html
- systemctl restart apache2
EOT
  )
}
