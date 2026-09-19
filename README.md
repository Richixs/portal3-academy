# Unlock Protocol Plugin for WordPress — Improvements

This fork builds on the official [Unlock Protocol plugin for WordPress](https://github.com/unlock-protocol/unlock-wordpress-plugin) to make Unlock-gated content something any WordPress site owner can set up and customize entirely from the block editor — no Web3 development knowledge required, and no site-specific code.

Submitted for the **ETH Bolivia Buildathon 2026 — Unlock Protocol Bounty #1 (WordPress Plugin)**.

## What's new

The original plugin already covers the fundamentals well: connecting an Unlock account, configuring Locks, and gating a full post or a block of content. What was missing was **flexibility for the two states every gated block can be in — "no wallet session" and "no valid membership"** — and a couple of concrete bugs that got in the way of a reliable install. This fork adds:

### 1. Per-block appearance overrides
Previously, the login and purchase prompts were controlled by a single site-wide setting: every locked block on every page showed the identical button, text, and colors. Now each Unlock block can opt out of the global style and set its own button text, background/text color, alignment (left/center/right), and an optional description + image — without affecting any other block on the site.

### 2. Free-form content for both states
Beyond styling a button, an admin can now insert **any WordPress block** — an image, formatted text, columns, whatever the page needs — to replace the built-in prompt entirely for either state. This is implemented as two new container blocks (`Unlock: No Session Content` and `Unlock: No Membership Content`) that only appear nested inside the Unlock block. On render, the plugin looks for these containers in the block's already-rendered content and shows only the one that matches the visitor's actual state, falling back to the original button system when neither is used — so existing content isn't affected.

### 3. Login-prompt deduplication
A page with several locked blocks used to repeat the full login prompt (description, image, button) once per block for a visitor with no wallet session — noisy and confusing. Only the first occurrence now renders in full; the rest show a compact link instead.

## How it maps to the bounty requirements

| Requirement | How this fork addresses it |
|---|---|
| Install and configure Unlock from WordPress | Unchanged from upstream: admin settings screen under **Settings → Unlock Protocol**. |
| Connect content/experiences to a membership | The `unlock-protocol/unlock-box` block, plus full-post locking. |
| Define which Lock grants access | Lock configuration UI in the block sidebar (upstream feature). |
| Restrict content based on membership validity | Core plugin logic (`Unlock::render_content()`), unchanged in behavior when no per-block override is used. |
| Clear path to obtain a membership | Built-in checkout button, now stylable/replaceable per block — see "Free-form content" above. |
| No Web3 dev knowledge required from site owners | Everything above is configured through the block editor's sidebar; no code or wallet-level knowledge needed. |
| Reusable across different WordPress sites | Every new feature is a per-block *override* of a site-wide default — nothing is hardcoded to a specific site, lock, or theme. |

## Installation

1. Clone this repository (or add it as a submodule of your WordPress project).
2. Install the JS dependencies and build the assets:
   ```bash
   yarn install
   yarn build:all
   ```
3. Copy the `unlock-wordpress-plugin/` directory (the one containing `unlock-protocol.php`) into your site's `wp-content/plugins/`, keeping the compiled `assets/build/` folder produced by the previous step.
4. Activate **Unlock Protocol** from the WordPress admin **Plugins** screen.
5. Go to **Settings → Unlock Protocol** to configure your network(s) and default appearance.

## Using the new features

1. Add the **Unlock Protocol** block to a post or page and configure the Lock(s) that should gate it.
2. Add your protected content inside the block as usual (any WordPress blocks).
3. To customize the login/purchase experience for *this block only*, open the block's sidebar panels **"Appearance — no wallet session"** and **"Appearance — no membership"**, turn off "Use the site-wide appearance settings", and set your own text, colors, and alignment.
4. For full creative control, insert an **"Unlock: No Session Content"** and/or **"Unlock: No Membership Content"** block inside the Unlock block, and add whatever content you want inside each — it replaces the button entirely for that state.

## Demo

A working installation demonstrating this fork is available in the companion [`portal3-academy`](https://github.com/Richixs/portal3-academy) repository, deployed at `portal3-academy.sasxr.com`. It uses a real Lock deployed on a public testnet to gate course content, with the video demo covering the full unauthenticated → purchase → unlocked flow.

## License

GPLv3, same as the upstream plugin. See [`unlock-wordpress-plugin/LICENSE`](./unlock-wordpress-plugin/unlock-wordpress-plugin/LICENSE).

---

# Plugin de Unlock Protocol para WordPress — Mejoras

Este fork parte del [plugin oficial de Unlock Protocol para WordPress](https://github.com/unlock-protocol/unlock-wordpress-plugin) para que el acceso gateado por Unlock sea algo que cualquier dueño de un sitio WordPress pueda configurar y personalizar por completo desde el editor de bloques — sin necesitar conocimientos de desarrollo Web3, y sin código específico para un solo sitio.

Presentado para el **ETH Bolivia Buildathon 2026 — Bounty #1 de Unlock Protocol (Plugin de WordPress)**.

## Qué hay de nuevo

El plugin original ya cubre bien lo fundamental: conectar una cuenta de Unlock, configurar Locks, y bloquear un post completo o un bloque de contenido. Lo que faltaba era **flexibilidad para los dos estados en los que puede estar cualquier bloque bloqueado — "sin sesión de wallet" y "sin membresía válida"** — además de un par de bugs concretos que dificultaban una instalación confiable. Este fork agrega:

### 1. Personalización de apariencia por bloque
Antes, los mensajes de login y compra dependían de una única configuración global del sitio: todo bloque bloqueado en cualquier página mostraba el mismo botón, texto y colores. Ahora cada bloque de Unlock puede optar por salir del estilo global y definir su propio texto de botón, color de fondo/texto, alineación (izquierda/centro/derecha), y opcionalmente una descripción + imagen — sin afectar a ningún otro bloque del sitio.

### 2. Contenido libre para ambos estados
Más allá de personalizar un botón, un administrador ahora puede insertar **cualquier bloque de WordPress** — una imagen, texto con formato, columnas, lo que la página necesite — para reemplazar por completo el mensaje predeterminado en cualquiera de los dos estados. Esto se implementa como dos bloques contenedores nuevos (`Unlock: No Session Content` y `Unlock: No Membership Content`) que solo aparecen anidados dentro del bloque de Unlock. Al renderizar, el plugin busca estos contenedores dentro del contenido ya renderizado del bloque y muestra solo el que corresponde al estado real del visitante, cayendo al sistema de botón original cuando ninguno de los dos se usa — así que el contenido existente no se ve afectado.

### 3. Deduplicación del mensaje de login
Una página con varios bloques bloqueados repetía el mensaje completo de login (descripción, imagen, botón) una vez por cada bloque para un visitante sin sesión de wallet — repetitivo y confuso. Ahora solo la primera aparición se muestra completa; el resto muestra un link compacto en su lugar.

## Cómo se relaciona con los requisitos del bounty

| Requisito | Cómo lo aborda este fork |
|---|---|
| Instalar y configurar Unlock desde WordPress | Sin cambios respecto al original: pantalla de ajustes en **Settings → Unlock Protocol**. |
| Conectar contenido/experiencias a una membresía | El bloque `unlock-protocol/unlock-box`, además del bloqueo de post completo. |
| Definir qué Lock otorga el acceso | UI de configuración de Lock en el sidebar del bloque (feature original). |
| Restringir contenido según validez de membresía | Lógica central del plugin (`Unlock::render_content()`), sin cambios de comportamiento cuando no se usa un override por bloque. |
| Camino claro para obtener una membresía | Botón de checkout integrado, ahora personalizable/reemplazable por bloque — ver "Contenido libre" arriba. |
| No requerir conocimientos de desarrollo Web3 del dueño del sitio | Todo lo anterior se configura desde el sidebar del editor de bloques; no hace falta código ni conocimiento a nivel de wallet. |
| Reutilizable en distintos sitios WordPress | Cada feature nueva es un *override* por bloque de un default del sitio — nada queda fijo a un sitio, lock o tema específico. |

## Instalación

1. Clona este repositorio (o agrégalo como submódulo de tu proyecto WordPress).
2. Instala las dependencias de JS y compila los assets:
   ```bash
   yarn install
   yarn build:all
   ```
3. Copia el directorio `unlock-wordpress-plugin/` (el que contiene `unlock-protocol.php`) a `wp-content/plugins/` de tu sitio, conservando la carpeta `assets/build/` generada en el paso anterior.
4. Activa **Unlock Protocol** desde la pantalla de **Plugins** del admin de WordPress.
5. Ve a **Settings → Unlock Protocol** para configurar tu(s) red(es) y la apariencia por defecto.

## Usando las funciones nuevas

1. Agrega el bloque **Unlock Protocol** a un post o página y configura el/los Lock(s) que deben protegerlo.
2. Agrega tu contenido protegido dentro del bloque normalmente (cualquier bloque de WordPress).
3. Para personalizar la experiencia de login/compra *solo para este bloque*, abre los paneles del sidebar **"Appearance — no wallet session"** y **"Appearance — no membership"**, desactiva "Use the site-wide appearance settings", y define tu propio texto, colores y alineación.
4. Para control creativo total, inserta un bloque **"Unlock: No Session Content"** y/o **"Unlock: No Membership Content"** dentro del bloque de Unlock, y agrega lo que quieras dentro de cada uno — reemplaza el botón por completo para ese estado.

## Demo

Una instalación funcionando que demuestra este fork está disponible en el repositorio complementario [`portal3-academy`](https://github.com/Richixs/portal3-academy), desplegada en `portal3-academy.sasxr.com`. Usa un Lock real desplegado en una testnet pública para proteger contenido de cursos, con el video demo cubriendo el flujo completo desde no autenticado → compra → contenido desbloqueado.

## Licencia

GPLv3, igual que el plugin original. Ver [`unlock-wordpress-plugin/LICENSE`](./unlock-wordpress-plugin/unlock-wordpress-plugin/LICENSE).
