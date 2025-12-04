# netdevops-ansible-lab

Proyecto para automatización con Ansible de una pequeña infraestructura de red.

## Descripción

Este proyecto proporciona una solución de Infrastructure as Code (IaC) para automatizar la configuración y gestión de una red pequeña que incluye:

- **Router Cisco IOS** - Configuración básica, NTP, DNS, logging
- **Switch Cisco Small Business** - Configuración de VLANs y hostname
- **Raspberry Pi** - Configuración base, hardening y firewall

## Características

- 🐳 Imagen Docker personalizada con Ansible y dependencias de red
- 🔄 GitHub Actions para CI/CD automático
- 📦 Colecciones Ansible para dispositivos de red
- 🔐 Soporte para Ansible Vault (gestión segura de credenciales)
- 📋 Playbooks modulares y reutilizables

## Estructura del Proyecto

```
.
├── Dockerfile                    # Imagen Docker personalizada de Ansible
├── .github/
│   └── workflows/
│       └── docker-build.yml      # Workflow para build de imagen Docker
└── ansible/
    ├── ansible.cfg               # Configuración de Ansible
    ├── inventory/
    │   └── hosts.yml             # Inventario de dispositivos
    └── playbooks/
        ├── cisco_router_config.yml    # Configuración router Cisco
        ├── switch_config.yml          # Configuración switch
        ├── raspberry_pi_config.yml    # Configuración Raspberry Pi
        ├── backup_configs.yml         # Backup de configuraciones
        └── gather_facts.yml           # Recolección de información
```

## Requisitos Previos

- Docker instalado localmente (para desarrollo)
- Acceso a los dispositivos de red
- Credenciales configuradas (preferiblemente con Ansible Vault)

## Uso

### Construir la imagen Docker localmente

```bash
docker build -t netdevops-ansible .
```

### Ejecutar un playbook

```bash
# Usando la imagen Docker
docker run --rm -v $(pwd)/ansible:/ansible netdevops-ansible \
    ansible-playbook playbooks/cisco_router_config.yml

# O directamente con Ansible instalado
cd ansible
ansible-playbook playbooks/raspberry_pi_config.yml
```

### Ejecutar con tags específicos

```bash
ansible-playbook playbooks/cisco_router_config.yml --tags "ntp,dns"
```

### Backup de configuraciones

```bash
ansible-playbook playbooks/backup_configs.yml
```

## Configuración del Inventario

Edita `ansible/inventory/hosts.yml` con las IPs reales de tus dispositivos:

```yaml
all:
  children:
    network:
      children:
        routers:
          hosts:
            cisco_router:
              ansible_host: <IP_DEL_ROUTER>
        switches:
          hosts:
            small_business_switch:
              ansible_host: <IP_DEL_SWITCH>
    servers:
      hosts:
        raspberry_pi:
          ansible_host: <IP_DE_LA_RASPBERRY>
```

## Gestión de Credenciales

Para gestionar credenciales de forma segura, usa Ansible Vault:

```bash
# Crear archivo de vault
ansible-vault create ansible/inventory/group_vars/all/vault.yml

# Editar archivo de vault
ansible-vault edit ansible/inventory/group_vars/all/vault.yml

# Ejecutar playbook con vault
ansible-playbook playbooks/cisco_router_config.yml --ask-vault-pass
```

## CI/CD con GitHub Actions

El workflow de GitHub Actions:

1. Se ejecuta automáticamente en push/PR a `main`
2. Construye la imagen Docker
3. Ejecuta `ansible-lint` para validar playbooks
4. Publica la imagen en GitHub Container Registry (ghcr.io)

### Imagen Docker disponible

```bash
docker pull ghcr.io/jiocariz/netdevops-ansible-lab:latest
```

## Playbooks Disponibles

| Playbook | Descripción |
|----------|-------------|
| `cisco_router_config.yml` | Configuración básica del router Cisco |
| `switch_config.yml` | Configuración de VLANs y hostname del switch |
| `raspberry_pi_config.yml` | Configuración y hardening de Raspberry Pi |
| `backup_configs.yml` | Backup de configuraciones de red |
| `gather_facts.yml` | Recolección de información de dispositivos |

## Colecciones Ansible Incluidas

- `cisco.ios` - Módulos para Cisco IOS
- `community.network` - Módulos para dispositivos de red genéricos
- `community.general` - Módulos generales de la comunidad
- `ansible.netcommon` - Funcionalidades comunes de red
- `ansible.posix` - Módulos POSIX para sistemas Linux

## Contribuir

1. Haz fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit de tus cambios (`git commit -am 'Añade nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## Licencia

Este proyecto está licenciado bajo MIT License - ver el archivo [LICENSE](LICENSE) para más detalles.
