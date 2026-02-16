# Minecraft Docker CobbleVerse (Rubius-style)

Servidor de Minecraft listo para usar con Docker, basado en **CobbleVerse** y pensado para gente que no quiere pelearse con instalaciones manuales.

Con este repo haces:

```bash
docker compose up -d
```

y el servidor descarga modpack + mods, activa pregeneracion y queda operativo.

## Tabla de contenido

- [Que trae este proyecto](#que-trae-este-proyecto)
- [Inicio rapido (para principiantes)](#inicio-rapido-para-principiantes)
- [Mapa mental de carpetas (importante)](#mapa-mental-de-carpetas-importante)
- [Como manejar configuraciones sin romper nada](#como-manejar-configuraciones-sin-romper-nada)
- [Ajustes ya activos](#ajustes-ya-activos)
- [Progreso por regiones (grupo)](#progreso-por-regiones-grupo)
- [Pregeneracion automatica](#pregeneracion-automatica)
- [Actualizaciones y rollback](#actualizaciones-y-rollback)
- [Modo local liviano](#modo-local-liviano)
- [FAQ rapida](#faq-rapida)
- [Creditos y aviso](#creditos-y-aviso)

## Que trae este proyecto

- CobbleVerse (Modrinth) para Minecraft `1.21.1`.
- Mods extra compatibles instalados automaticamente.
- Pregeneracion automatica de chunks con Chunky.
- Backups diarios automaticos.
- Flujo de progreso por regiones (Kanto al inicio).
- Configs versionadas para no perder ajustes al actualizar.

## Inicio rapido (para principiantes)

1. Clona el repo.
2. Crea `.env` desde ejemplo:

```bash
cp .env.example .env
```

3. Edita `.env` y cambia `RCON_PASSWORD` por una clave segura.
4. Inicia el servidor:

```bash
docker compose up -d
```

5. Mira logs:

```bash
docker logs -f cobbleverse-docker
```

## Mapa mental de carpetas (importante)

- `docker-compose.yml`: infraestructura del servidor (RAM, puertos, backups, RCON, etc).
- `config/`: **overrides** versionados (tus ajustes permanentes).
- `data/`: datos runtime generados (mundo, mods descargados, configs autogeneradas).
- `scripts/`: utilidades de update, rollback y mantenimiento.

### Que es obligatorio y que es opcional

- Obligatorio: `docker-compose.yml`, `.env`, `config/`, `scripts/`, `data/datapacks/`.
- Opcional: `docker-compose.local.yml` (solo pruebas locales de bajo consumo).
- Opcional/experimental: `docker-compose.arclight.yml` (no usar en produccion hasta confirmar compatibilidad con tu version del pack).

Referencia completa: `https://github.com/eztato/cobbleverse-docker/wiki/Configuracion-y-Capas`

## Como manejar configuraciones sin romper nada

Regla simple:

- Si quieres que un cambio sobreviva updates y quede en git, debe vivir en `config/`.
- Si solo editas en `data/config`, ese cambio se puede perder o quedar desordenado.

Flujo recomendado:

1. Arranca el server y deja que genere todo en `data/`.
2. Edita y prueba en `data/config/...`.
3. Cuando te guste el resultado, promueve el archivo a `config/`:

```bash
./scripts/promote-config.sh data/config/cobblemon/main.json
```

Eso copia el archivo a `config/...` respetando estructura y hace backup del override anterior si existia.

## Ajustes ya activos

- `playerDamagePokemon=true` en `config/cobblemon/main.json` (se puede golpear pokemon salvaje).
- `config/cobblemon/main.json` se guarda completo (no parcial) para evitar perder otros ajustes del pack.
- `ENABLE_COMMAND_BLOCK=true` en `docker-compose.yml` (requerido para varias estructuras/funciones).

## Progreso por regiones (grupo)

Modo pensado para que el grupo avance junto:

- Region inicial: `Kanto`.
- Siguiente orden recomendado (oficial): `Johto -> Hoenn -> Sinnoh`.
- `Unova` puede manejarse como contenido custom opcional si tienes datapacks compatibles.

Cuando todos terminen su cup:

1. Mueve datapacks de la siguiente region desde `data/datapacks/extra/` a `data/datapacks/`.
2. Ejecuta setup regional por RCON.
3. Reinicia una vez el servidor.

Comandos utiles:

```bash
docker exec cobbleverse-docker rcon-cli "datapack list"
docker exec cobbleverse-docker rcon-cli "function setup:johto"
docker exec cobbleverse-docker rcon-cli "function setup:hoenn"
docker exec cobbleverse-docker rcon-cli "function setup:sinnoh"
docker compose restart cobbleverse-docker
```

Guia operativa detallada: `https://github.com/eztato/cobbleverse-docker/wiki/Regiones-y-Progresion`

## Pregeneracion automatica

Al arrancar, Chunky intenta generar:

- Overworld: radio 5000
- Nether: radio 2500
- End: radio 2000

Y ademas:

- Entra primer jugador -> pausa (`chunky pause`)
- Sale ultimo jugador -> reanuda (`chunky continue`)

Estado actual:

```bash
docker exec cobbleverse-docker rcon-cli "chunky progress"
```

## Actualizaciones y rollback

Este proyecto esta en modo **versiones pinneadas por tag** (reproducible y mantenible):

- `itzg/minecraft-server:java21`
- `itzg/mc-backup:2026.2.0`
- CobbleVerse + mods extra en release mas reciente compatible

Recomendacion: actualizar en una ventana fija (por ejemplo semanal), revisar compatibilidad y volver a pinnear si todo va bien.

Update seguro (backup previo + pull + up):

```bash
./scripts/update-safe.sh
```

Si algo sale mal:

```bash
./scripts/rollback-last-update.sh
```

## Modo local liviano

Para probar en PC justas de RAM:

```bash
docker compose -f docker-compose.yml -f docker-compose.local.yml up -d
```

## FAQ rapida

- No arranca compose y dice `RCON_PASSWORD missing` -> crea `.env` desde `.env.example`.
- No ves cambios de config -> reinicia `cobbleverse-docker` tras tocar `config/`.
- No aparecen estructuras de region nueva -> revisa `datapack list`, ejecuta `setup:*` y reinicia una vez.

## Creditos y aviso

- Proyecto fan-made para facilitar despliegue.
- No oficial de Mojang/Microsoft.
- Respeta licencias de mods/datapacks/resourcepacks.
