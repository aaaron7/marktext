# Repository Guidelines

## Project Structure & Module Organization
MarkText is an Electron app split across a few clear areas. `src/main` contains Electron main-process code, `src/renderer` holds the Vue UI, `src/common` contains shared Node-safe utilities, and `src/muya` is the editor core and must stay free of Electron and Node.js APIs. Tests live in `test/unit` and `test/e2e`. Static runtime assets are in `static/`, packaged resources and installer assets are in `resources/`, and longer-form docs are in `docs/`. Generated output goes to `dist/` and `build/`.

## Build, Test, and Development Commands
Use Node `16.x` and Yarn.

- `yarn install --frozen-lockfile`: install dependencies exactly as locked.
- `yarn dev`: start MarkText in development mode.
- `yarn lint` / `yarn lint:fix`: check or auto-fix ESLint issues in `src` and `test`.
- `yarn unit`: run Karma unit tests with Mocha/Chai.
- `yarn e2e`: pack the app and run Playwright end-to-end tests.
- `yarn test`: run the full test suite.
- `yarn build:bin`: create unpacked binaries for the current OS.
- `yarn build`: build distributable packages with `electron-builder`.
- `yarn validate-licenses`: run the license validation step used in CI.

## Coding Style & Naming Conventions
Follow `.editorconfig`: UTF-8, LF line endings, final newline, and 2-space indentation. ESLint extends Standard and Vue rules; semicolons are disallowed. Prefer small, focused modules and keep cross-process utilities in `src/common` when possible. Existing filenames mostly use lower camelCase such as `loadmode.js` or `editor.js`; keep new test files in `*.spec.js`. Add JSDoc for non-obvious public behavior.

## Testing Guidelines
Unit specs live in `test/unit/specs` and commonly use fixtures from `test/unit/data` or `test/specs`. End-to-end tests live in `test/e2e/*.spec.js` and run with a single Playwright worker, so avoid flaky timing assumptions. Before opening a PR, run `yarn lint`, `yarn unit`, and any affected `yarn e2e` flows. Coverage output is written to `coverage/`.

## Commit & Pull Request Guidelines
Recent commits favor short imperative subjects, often with prefixes like `chore:` and issue references. For bug fixes, follow the existing pattern from `CONTRIBUTING.md`: `fix: #3150 short message`. Open pull requests against `develop`, not `main`. Complete `.github/PULL_REQUEST_TEMPLATE.md`, link related issues, describe the change clearly, and include screenshots or screen recordings for UI work. CI is expected to pass linting, license checks, tests, and `yarn build:bin`.
