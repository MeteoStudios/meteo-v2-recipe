# Meteo V2 Package - txAdmin Recipe

Deploys the [Meteo Studios V2 package](https://meteostudios.net/meteo-v2-package) with txAdmin. Version v2.12.0.

Don't have the package yet? Get it at https://meteostudios.net/meteo-v2-package

Made in collaboration with Prompt Studio. The package locations are built for
the Meteo V2 maps package from Prompt Studio: https://store.prompt-mods.com/store/package/7718215

## Deploy

1. In txAdmin's setup, pick **Remote URL Template**.
2. Paste the recipe URL:
   ```
   https://raw.githubusercontent.com/MeteoStudios/meteo-v2-recipe/main/recipe.yaml
   ```
3. Fill in your license key and database details and run the deployer.

## Manual install

If the txAdmin recipe fails, download **meteo-v2-package-recipe.zip** from the
[latest release](https://github.com/MeteoStudios/meteo-v2-recipe/releases/latest) instead.

1. Extract it and use `server-data` as your server folder.
2. Import `database/meteov2.sql`, then `database/meteov2data.sql`. They create
   the `meteov2` database, which `server.cfg` already connects to.
3. In `server.cfg`, put your license key in `sv_licenseKey`.
4. In `permissions.cfg`, put your own license in the `YOUR_LICENSE_HERE` line
   to make yourself admin.

## After deploying

- **Meteo Studios Scripts Bundle:** download them from the CFX portal (https://portal.cfx.re/)
  and drop the **[meteostudios]** folder into `resources/`. Not bought yet? Get
  the package at https://meteostudios.net/meteo-v2-package
- **Renaming the scripts (optional):** run `tools/meteo-rename.bat` in your
  server folder after the scripts are in place and point it at that folder.
- **Prompt Studio maps:** the package locations are made for these maps. Get the
  Meteo V2 maps package (https://store.prompt-mods.com/store/package/7718215), download Part 1, Part 2 and Part 3
  from the CFX portal and drop them into `resources/[assets]/[prompt-maps]/`.
  Guide: https://docs.meteostudios.net/packages/meteo-v2-package/installation-guide#prompt-studio-maps

## Help

- Docs: https://docs.meteostudios.net/packages/meteo-v2-package
- Discord: https://discord.gg/P5cPsVTNZf

Third-party resources keep their own licenses - see [CREDITS.md](CREDITS.md).
