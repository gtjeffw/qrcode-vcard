# Developing QR VCard Share

How the shortcut is built, tested and structured, and the Shortcuts and Cherri behaviours it works
around. For what it does and how to use it, see the [README](../README.md).

## Building

Requires macOS with the Shortcuts app, and Go (`brew install go`).

```bash
scripts/setup-cherri.sh
```

```bash
scripts/build.sh
```

```bash
open "build/QR VCard Share.shortcut"
```

`setup-cherri.sh` clones Cherri into `tools/cherri` at a pinned commit, applies the patches in
`patches/cherri/`, and builds the compiler. `build.sh` compiles `src/qr_vcard_share.cherri` (or the
files you name) into `build/` and signs it. Opening the signed file brings up Shortcuts' import
dialog. Replacing an existing copy from that dialog has proved unreliable (it tends to add "QR VCard
Share 1" instead), so delete the old shortcut first, then add the new one. Shortcuts syncs it to
your other devices through iCloud.

`build.sh` signs only with the local `shortcuts sign` command. Cherri's built-in signing falls back to
uploading the shortcut to a third-party service (HubSign) when local signing fails, which is not what
you want for a shortcut that handles contact data, so don't run `cherri` on these files without
`--skip-sign`.

To try a change without touching the installed release, build a copy under another name, so it
installs as a separate shortcut. It shares the release's `QRVCard/` settings:

```bash
cp -R src /tmp/testing-src && sed -i '' 's/^#define name .*/#define name QR VCard Testing/' /tmp/testing-src/qr_vcard_share.cherri
```

```bash
scripts/build.sh /tmp/testing-src/qr_vcard_share.cherri
```

## Releasing

The README's "Get the shortcut" button links to an iCloud share of the shortcut. A share link is a
snapshot of the shortcut at the time it was shared, so each release needs a new one:

1. Set the new version in `AppVersion` in `src/qr_vcard_share.cherri`.
2. Build with `scripts/build.sh`, delete the old QR VCard Share in Shortcuts, and add the new build.
3. In Shortcuts, choose Share → Copy iCloud Link on it.
4. Put the new version and link in `latest.json`, replace the link in README.md, and push.

`latest.json` is what **About** → **Check for updates** reads, from
`https://raw.githubusercontent.com/gtjeffw/qrcode-vcard/main/latest.json`. Installed copies compare
its `version` with their own `AppVersion` and offer its `install` link when they differ, so update it
only once the new link exists.

The shared copy holds only the shortcut itself (including the made-up self-test contacts); nobody's
`QRVCard/` settings travel with it.

## Layout

| Path | |
|---|---|
| `src/qr_vcard_share.cherri` | The shortcut: menus, identity, choosing a profile, show and share. |
| `src/identity_lookup.cherri` | Finds the saved identity's card in Contacts and uses it as it is now, saving it again when its name, emails or phones change. |
| `src/vcard_parse.cherri` | Parses a contact's vCard text into fields and labelled phone/email/address lines. |
| `src/profiles.cherri` | Loads the profiles, creating the starting set the first time. |
| `src/profile_edit.cherri` | Adds, edits, renames and deletes profiles. |
| `src/select_lines.cherri` | Picks the entries for a contact and profile: label matching, remembered answers, prompts. |
| `src/vcard_text.cherri` | Builds the output vCard and the card's text. |
| `src/card_image.cherri` | Renders the QR code and the details into the card image. |
| `src/selftest.cherri` | Made-up contacts and profiles for the self-tests. |
| `patches/cherri/` | Fixes to Cherri that this project needs (below); GPL-2.0, like Cherri. |
| `docs/` | This file, and `images/` for the README. |
| `latest.json` | Latest released version and its install link, read by Check for updates. |
| `scripts/` | Cherri setup and the build. |

The `src/` files other than the shortcut are pulled in with `#include`, which Cherri inlines as
text: each defines constants, so each can be included only once per shortcut.

## Testing

The shortcut has a self-test mode: given the text `selftest` as input, it skips the menus and every
file, runs the parsing, label matching and rendering on a made-up contact, and outputs the card
image. `selftest-sparse` does the same for a card with only a name line and a mobile number, under a
profile with missing keys. `selftest-burdell` and `selftest-doe` render the README's example cards.
`src/selftest.cherri` lists what each should produce. Inputs not starting with `selftest` are read as
the quick-launch commands described in the README (`show:<profile>` and so on); anything else opens
the main menu.

```bash
printf selftest > selftest.txt
```

```bash
shortcuts run "QR VCard Share" --input-path selftest.txt --output-path card.png
```

```bash
zbarimg --raw -q card.png
```

`zbarimg` (`brew install zbar`) decodes the QR code so you can check the vCard.

The menus, contact picker, prompts and permission dialogs can only be tested by running the shortcut
yourself. When a run fails, the system log names each action and how many items it produced:

```bash
/usr/bin/log show --last 5m --style compact --predicate 'process == "BackgroundShortcutRunner" AND eventMessage CONTAINS "finished with"'
```

## Cherri patches

Built against Cherri `bcc0095` (v2.3.0 plus later fixes), with four patches. Each lives on its own
branch in the fork [gtjeffw/cherri](https://github.com/gtjeffw/cherri), based on upstream `main` and
written to Cherri's contribution guidelines, so it can become a pull request later. The
`qrcode-vcard` branch stacks all four, and `patches/cherri/` is generated from it
(`git format-patch -o <repo>/patches/cherri bcc0095..qrcode-vcard`).

| Branch | Fix |
|---|---|
| `fix-raw-action-assigned-identifier` | `const x = rawAction("id", {...})` compiled to `is.workflow.actions.rawaction`, which Shortcuts does not recognise. |
| `fix-rich-text-input-attachment` | `getRichTextFromHTML()` and `getRichTextFromMarkdown()` wrapped a variable input in a text token string, and Shortcuts then produced no rich text. A literal string argument is still discarded, as before. |
| `add-contact-email-phone-details` | Adds `Email Addresses` and `Phone Numbers` to the contact detail list. |
| `add-find-contacts-filters` | Adds `findContacts("all" or "any", property, operator, value, ...)`, Find Contacts with filter conditions, which `filterContacts()` can't express (upstream #128). Property and operator are checked at compile time. |

To move to a newer Cherri: rebase the branches onto the new upstream `main`, rebuild `qrcode-vcard`,
regenerate the patches, and update the commit in `scripts/setup-cherri.sh`.

Candidates for further upstream issues or patches, worked around here for now:

- `combineImages()` compiles to an identifier Shortcuts does not have (likely should be
  `image.combine`; confirm against a shortcut built in the app).
- `overlayImage()` always opens the image editor at run time.
- Entries with empty values are dropped from dictionary literals.
- Strings have no way to contain a literal `{` or `}`.
- A shortcut whose first action is a multi-word Text action crashes Shortcuts' import dialog on
  macOS 26.7; the compiler could inject a harmless first action (needs testing which).
- `splitText()` without a separator panics the compiler (in `textParts`); pass `"\n"`.
- Output is not reproducible even with `--derive-uuids`: dictionary entries come out in Go's random
  map order.

The Shortcuts behaviours below are better suited to Cherri's documentation than to the compiler.

## Shortcuts and Cherri quirks

Things that cost time here and are easy to trip over again:

- **Import dialog crash.** Shortcuts on macOS 26.7 crashes when showing the import dialog for a
  shortcut whose *first* action is a Text action holding more than one plain word. Start with any
  other action (the shortcut begins by setting `@Mode`).
- **Layout differs between macOS and iOS.** Turning HTML into rich text honours CSS padding on macOS
  but not on iOS, and images render at screen scale (2x on the Mac). The card is assembled from
  separately rendered images placed at fixed pixel positions with Custom Image Overlay, each scaled
  back to 600 px wide first. The QR code is at the top because iOS puts its Live Text button in an
  image's bottom corner.
- **Reading a `.vcf`.** Shortcuts reads a `.vcf` file back as a contact, whose text is just the name.
  Renaming it to `.txt` before Get Text gives the vCard text. Set Name on a contact from Find
  Contacts works the same way in memory, with no file, and gives exactly what saving it would write.
  A picked contact is still read through a saved file.
- **Contact data and permission prompts.** Shortcuts asks before writing anything derived from a
  contact to a file (even a hash of it), every time; Always Allow doesn't stick. Reading contacts and
  files doesn't ask. So write contact data only when it has to: the identity is used straight from
  Contacts, and its saved copy is replaced only when what identifies the card changes.
- **Find Contacts filters.** Each condition's value sits under a key that depends on the property
  (`Email` for Email Addresses, `Phone` for Phone Numbers, `String` otherwise); with the wrong key, or
  an unknown property, Shortcuts silently drops the condition and matches everything. `findContacts()`
  in the patched Cherri takes care of this. Phone numbers are stored as typed, so match a few
  trailing digits with "contains" rather than the whole number.
- **Linked cards.** Find Contacts returns each card of a set linked in Contacts on its own, and saving
  one saves only that card. The contact picker returns the linked set as one merged card.
- **Empty text counts as a value.** `if @x` is true for an empty text; compare with `!= ""` instead.
  But Replace Text on an *empty input* returns nothing at all, which doesn't equal `""`, so wrap a
  result as text (`@x = "{Result}"`) before comparing it.
- **Dictionaries.** Set Dictionary Value refuses an empty value, and Get Dictionary Value reads a
  missing key containing `.` (as in an email address) as a key path and fails. Every value stored here
  is non-empty (`,` or `-` stand for "none"), and every key that is read is always present. Cherri
  also drops entries with empty values from dictionary literals.
- **Cherri actions to avoid.** `overlayImage()` opens the image editor at runtime (use
  `customImageOverlay()`), and `combineImages()` compiles to an identifier Shortcuts does not have.
  `rawAction()` turns nested dictionaries into Shortcuts dictionary values, so contact filters can't
  be expressed with it (use the patched `findContacts()`).
- **Command-line runs.** `shortcuts run` can't show permission prompts, so run a shortcut once in the
  app to grant iCloud Drive access before running it from the terminal.
