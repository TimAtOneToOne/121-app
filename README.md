# 121

Flutter implementation of the [121 care dashboard in Figma](https://www.figma.com/design/yDOPOIMvUSJeOOBMKFS5E7/Corporate-Wellness-Challenge?node-id=88-15675&m=dev).

## Try it in Chrome

From this folder, run:

```sh
make run
```

This opens the app in Chrome. Resize the window to a phone width (the Figma frame is 390 × 919). Try the conversation card, care shortcuts, date picker, challenge, and bottom navigation.

While the command is running, press `r` to reload code changes, `R` to restart the app, or `q` to stop. You can also use VS Code with the recommended Flutter extension: open `lib/main.dart`, select Chrome as the device, and press F5.

The equivalent direct command is:

```sh
.tmp/flutter-sdk/bin/flutter run -d chrome
```

The Flutter 3.47.7 SDK is installed locally under the ignored `.tmp/flutter-sdk` directory. VS Code is configured to find it there. On a fresh clone, install [Flutter](https://docs.flutter.dev/install/manual), then either put its SDK at that path or adjust `.vscode/settings.json` to your installed SDK. `make` uses the local SDK when present and otherwise uses Flutter on your PATH. Run `flutter pub get` after setting up a fresh clone.

## What works

The home screen uses the Figma colors, local icon/background exports, Instrument Sans, and Family Light. It adapts to narrow screens and larger text. The bottom bar stays fixed while the content scrolls. The app leaves time, signal, and battery indicators to the device; the browser demo has no simulated status bar.

The 26 additional current light-theme screens and states are implemented: challenge onboarding and profile/photo selection, property search, challenge lists and details, joining, progress, both leaderboards, manual logging, document and photo submissions, the learning module and quiz, submission/completion states, health data sharing, device selection, and Apple Health/Garmin connection previews.

Start with **Join Challenge** on Home or **Health** in the bottom bar. **Settings → Explore all screens** opens a gallery of every design state. You can also append `?screen=gallery` to the app URL, or use a page name such as `?screen=profile` or `?screen=progress`. The frame-to-page mapping is in `lib/wellness/state.dart`.

Names, challenge membership, logs, quiz completion, and uploaded-file metadata update within the session. File/photo selection uses the platform picker; submissions are local previews and are not transmitted. Refreshing resets the demo. Seeded records, rankings, dates, points, review approvals, and connected-device readings are demo fixtures. Permission sheets simulate consent without requesting health access. The learning video is a poster preview; its lesson and quiz are interactive. Reminder preferences do not schedule notifications.

There is no backend, account authentication, real message delivery, lab ordering, or health-data integration. The date picker opens a visit-request conversation; it does not book an appointment. Care-team and records tabs remain placeholders outside the selected Figma flow.

## Automated checks

```sh
make check
make build
```

`check` verifies formatting, runs the Dart analyzer, and tests the dashboard, all 26 screen states at 390px and 320px widths, profile validation, activity credits, file removal, and connection consent. `build` produces the web app in `build/web`.

## Share a browser demo

The deployed demo is at **https://121-demo.pages.dev/**. Open **https://121-demo.pages.dev/?screen=gallery** to browse every screen. This is a public demo with session-only state.

To publish an update to the existing Cloudflare Pages project, keep `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` in the ignored `.env`, then run:

```sh
make check
make build
npm install --prefix .tmp/cloudflare-tools --no-audit --no-fund wrangler@4.151.0
node --env-file=.env .tmp/cloudflare-tools/node_modules/wrangler/bin/wrangler.js pages deploy build/web --project-name=121-demo --branch=main --commit-dirty=true
```

Node.js 22 or newer is required. The deployment uploads only `build/web`; the token stays local. This directly publishes the current working tree, including uncommitted app changes. The existing project uses Pages Direct Upload. When creating a new Pages project with Wrangler 4.151.0, its `pages project create` command needs `--force` to bypass automatic Workers deployment; existing Pages projects deploy normally.

For a ZIP to upload manually:

```sh
make demo
```

This builds the release web app and packages `.tmp/121-demo.zip`, with `index.html` at the root. It includes only the compiled web app and bundled assets, not repository files or `.env`.

For an upload-based deployment, sign in to [Cloudflare Pages](https://developers.cloudflare.com/pages/get-started/direct-upload/), open **Workers & Pages → Create application → Get started → Drag and drop your files**, choose a project name, upload `.tmp/121-demo.zip`, and select **Deploy site**. Share the resulting HTTPS `pages.dev` URL. Anyone with the link can open this unauthenticated demo in their browser. For later updates, build again and select **Create a new deployment** in that project.

A Direct Upload project cannot later switch to Git integration; create a separate Git-integrated project if you want automatic deployments. Flutter's [web deployment guide](https://docs.flutter.dev/deployment/web) explains other hosting options. Native distribution through TestFlight or Android testing is a separate step and needs platform signing and developer accounts.

## Test on a phone later

The iOS and Android projects are included. Native builds need Xcode and an iOS simulator/device, or Android Studio and an Android emulator/device. Once those tools are installed:

```sh
.tmp/flutter-sdk/bin/flutter doctor
.tmp/flutter-sdk/bin/flutter devices
.tmp/flutter-sdk/bin/flutter run -d <device-id>
```

The initial implementation is validated with widget tests and a Chrome web build. Native device builds have not been validated.

## Project files

- `lib/main.dart`: app theme, dashboard widgets, and local preview interactions.
- `assets/`: bundled Figma exports and fonts; no temporary Figma URLs are used at runtime.
- `lib/wellness/`: shared demo state, reusable UI, and the current Figma flows.
- `test/`: interaction and responsive layout checks.
- `.env`: ignored local configuration, currently unused. Never bundle secrets in a client app.
- `.tmp/`: ignored SDK, development tools, and preview screenshots; only `.gitkeep` is tracked.

Instrument Sans is distributed under its included OFL license. Family Light is the existing company font from `internal-chat-ui`, converted from WOFF2 to TTF for Flutter. Its original commercial license still applies. Blurred decorative layers are rasterized from the original Figma SVG exports so their filters render accurately on Flutter; icons remain SVGs.
