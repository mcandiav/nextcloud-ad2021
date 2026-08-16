# Nextcloud AD2021

## Estado

**Versión inicial:** `32.0.2-ad2021.1`  
**Base:** `nextcloud:32.0.2`  
**Entorno objetivo:** `ad2021.local`  
**Servicio productivo objetivo:** EasyPanel `asistente / ncloud`

## Objetivo

`nextcloud-ad2021` es una imagen corporativa derivada de la imagen oficial de Nextcloud. Su objetivo inicial es habilitar soporte SMB/CIFS para que el Nextcloud integrado con LDAP/Active Directory pueda montar recursos compartidos Windows.

Este repositorio **no es un fork del core de Nextcloud**. La aplicación y su ciclo de actualización continúan dependiendo de la imagen oficial upstream; aquí solo se agregan dependencias técnicas controladas.

## Arquitectura

```text
nextcloud:32.0.2
        |
        | Dockerfile derivado
        v
nextcloud-ad2021
        |
        | smbclient + PHP smbclient
        v
GHCR
        |
        v
EasyPanel / asistente / ncloud
        |
        | SMB/CIFS
        v
Servidor Windows / Active Directory
```

## Modificaciones sobre upstream

La versión `32.0.2-ad2021.1` agrega únicamente:

- binario `smbclient`;
- headers `libsmbclient-dev` durante compilación;
- librería runtime `libsmbclient0`;
- extensión PHP `smbclient` instalada mediante PECL.

El build elimina las dependencias de compilación y valida al final que:

```text
php -m
```

incluya `smbclient` y que el binario `smbclient` esté disponible.

## Build y publicación

GitHub Actions construye la imagen en cada cambio a `main` y publica en GHCR cuando el evento no es un Pull Request.

Tags previstos:

```text
ghcr.io/mcandiav/nextcloud-ad2021:32.0.2-ad2021.1
ghcr.io/mcandiav/nextcloud-ad2021:<commit-sha>
```

El tag por versión es el que deberá usar producción. No se recomienda usar `latest`.

## Política de actualización

Una actualización de Nextcloud debe seguir esta secuencia:

1. identificar una nueva imagen oficial de Nextcloud compatible;
2. cambiar explícitamente `NEXTCLOUD_IMAGE` en el Dockerfile;
3. incrementar la versión `*-ad2021.N`;
4. construir y validar la imagen;
5. revisar compatibilidad de LDAP, External Storage y SMB;
6. validar persistencia y rollback de `ncloud` en EasyPanel;
7. desplegar en producción solo después de aprobación.

## Pre-flight antes de producción

Antes de cambiar la imagen del servicio `ncloud` se debe confirmar:

- imagen/tag actualmente desplegado;
- volúmenes y mounts persistentes;
- variables de entorno y secretos;
- base de datos utilizada;
- estado de LDAP/AD;
- existencia de backup válido;
- ventana de mantenimiento;
- tag exacto de rollback.

No se debe desplegar esta imagen sobre producción hasta completar esas verificaciones.

## Rollback

La referencia conocida anterior al cambio SMB es:

```text
nextcloud:32.0.2
```

Si el despliegue derivado falla, EasyPanel debe volver a esa imagen manteniendo exactamente los mismos volúmenes, variables, redes y dominios del servicio `ncloud`.

## Seguridad

- No almacenar `.env`, contraseñas, tokens, certificados privados ni credenciales LDAP/SMB en este repositorio.
- Las credenciales de ejecución pertenecen a EasyPanel/Nextcloud o al mecanismo seguro correspondiente.
- No modificar el core de Nextcloud para resolver necesidades que puedan cubrirse con configuración estándar, Theming, apps o dependencias de imagen.

## Alcance futuro

El repositorio podrá incorporar otras dependencias técnicas requeridas por el entorno `ad2021.local`, siempre que cada incorporación sea mínima, documentada, versionada y validada. Cambios funcionales propios deben preferir una app de Nextcloud antes que modificaciones al core.
