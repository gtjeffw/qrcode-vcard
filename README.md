# QR VCard Share

**Show your contact card as a QR code that anyone can scan with their phone's camera, or send it as a
contact file, with exactly the details you choose.**

<!-- TODO before release: replace INSERT-ICLOUD-LINK with the shortcut's public iCloud link. -->
<p align="center">
  <a href="https://www.icloud.com/shortcuts/INSERT-ICLOUD-LINK">
    <img alt="Get the shortcut" src="https://img.shields.io/badge/Get%20the%20shortcut-iCloud-F48024?style=for-the-badge&logo=apple&logoColor=white">
  </a>
  <br>
  <sub>Opens in the Shortcuts app on iPhone, iPad or Mac</sub>
</p>

<p align="center">
  <img src="docs/images/card-burdell.png" width="300" alt="George P. Burdell's card: QR code above his name, title, Georgia Tech, work and mobile numbers and work email">
  &nbsp;&nbsp;
  <img src="docs/images/card-doe.png" width="300" alt="Jane Doe's card: QR code above her name, mobile and Lab numbers, home email, home address and birthday">
</p>

Meeting someone? Pick **Show my QR VCard**, choose how much to share, and hold up your phone. They
point their camera at the code and tap to save you as a contact, with every number and email under
the right label. No app needed on their side, and nothing you didn't pick is included.

## What it does

- **Show** your card, or anyone's from your contacts, as a QR code with the same details written
  underneath, so you both see exactly what's in it.
- **Share** a card as a contact file through Messages, AirDrop, Mail and the rest, after showing you
  the full list of what will be sent.
- **Profiles** decide what goes in: Business might be your work number and email with your job
  title; Personal your mobile, home email and address. Add, edit, rename and delete them.
- **Labels, not guesswork.** Profiles pick phone numbers, emails and addresses by their labels in
  Contacts (mobile, work, home, your own custom labels, or the one marked primary), so the same
  profile works for anyone's card.
- **Asks only when it has to.** If a card has nothing matching a profile, you choose once and the
  shortcut remembers your choice for that person.

## Install

1. Open the **Get the shortcut** link above on your iPhone, iPad or Mac and tap **Add Shortcut**.

   <img src="docs/images/install.png" width="260" alt="Shortcuts' Add Shortcut screen for QR VCard Share">

2. Run **QR VCard Share** and choose **Set your Identity**, then pick your own contact card.

You need the Shortcuts app and **iCloud Drive turned on**, because the shortcut keeps your settings
in the Shortcuts folder there. It has been tested on iOS 26 and macOS 26.

The first time it reads or saves its settings, Shortcuts asks for permission; choose **Always
Allow** so it stops asking.

## Using it

<p>
  <img src="docs/images/menu.png" width="240" alt="The main menu">
  <img src="docs/images/profile-choice.png" width="240" alt="Choosing a profile">
  <img src="docs/images/card-on-phone.png" width="240" alt="George P. Burdell's QR card on an iPhone">
</p>

| Menu item | What happens |
|---|---|
| **Show my QR VCard** | Choose a profile and your card appears as a QR code, ready to scan. |
| **Show a contact's QR VCard** | Same, for someone in your contacts. |
| **Share my VCard** | Shows the details that will be sent, then opens the share sheet with a contact file. |
| **Share a contact's VCard** | Same, for someone in your contacts. |
| **Set your Identity** | Picks your own card. Run it again after you edit your card in Contacts. |
| **Manage profiles** | Add, edit, rename or delete profiles. |

### Profiles

The first run sets up four profiles to start from:

| Profile | Includes |
|---|---|
| Business | Company, job title, department, work phone and work email |
| Personal | Mobile, home email, home address and birthday |
| Cell only | Just the mobile number |
| Everything | Every detail on the card |

Editing a profile asks two things: which categories to include (company, job title, department,
birthday, phone numbers, email addresses, addresses), and then, for phone numbers, emails and
addresses, which labels:

- **Phone numbers:** primary, all, mobile, iPhone, work, home, main, pager, other
- **Emails and addresses:** primary, all, home, work, other
- **Custom labels** on your own card, such as "Lab" or "school"

"Primary" is the entry Contacts marks as preferred. If a card has two entries with the same label,
both are included; choose primary to get just one.

<p>
  <img src="docs/images/profile-categories.png" width="240" alt="Choosing which categories a profile includes">
  <img src="docs/images/profile-edit.png" width="240" alt="Choosing which phone labels a profile includes">
</p>

### When it asks

The shortcut goes straight to the card when the profile decides everything. It asks only when a card
has entries in a category but none match the profile, for example someone with no mobile number under
Cell only. Your answer is remembered for that person and profile, so it doesn't ask again. It asks
again for a category only if you change that category's labels in the profile. To choose by hand for
one share, pick **Pick items manually…** in the profile list.

Missing details are simply left out: no address, no birthday, no department, no problem.

### Before sharing

**Share** always shows the complete list of what the contact file contains, with **OK** and
**Cancel**, so nothing goes out by accident. **Show** needs no preview: the card's text matches its QR
code exactly.

<img src="docs/images/share-preview.png" width="260" alt="The preview of what will be shared, with OK and Cancel">

## Privacy

- Everything stays on your devices and your iCloud Drive. The shortcut never sends anything anywhere
  unless you choose **Share**.
- Its settings are in the Shortcuts folder in iCloud Drive, under `QRVCard/`: a copy of your own card
  (from Set your Identity), your profiles, and remembered choices.
- Remembered choices never contain anyone's details: people are identified by a one-way hash of their
  name, and choices are hashes of the chosen entries. Phone numbers are few enough that a determined
  person with the file could work them out, so think of this as keeping details out of plain sight.
- When you show or share someone else's card, the shortcut briefly writes it to a scratch file to read
  it, then blanks that file straight away.

## Questions

**Shortcuts asks for permission again and again.** Choose **Always Allow** when it asks about iCloud
Drive or sharing data with another app; you can change this later in the shortcut's settings. The
prompt about saving a contact to a file can still come back for a contact it hasn't seen before:
that's the step that reads the contact's details, and Shortcuts asks per contact.

<img src="docs/images/permission.png" width="240" alt="Shortcuts asking to allow QR VCard Share to save a contact to a file">

**It stopped with "Location doesn't exist".** iCloud Drive is off. Turn it on in Settings > your name >
iCloud > iCloud Drive.

**I edited my contact card but the old details show.** Run **Set your Identity** again; the shortcut
keeps a copy of your card.

**Updating the shortcut added a second copy.** Shortcuts' **Replace** button adds a copy instead of
replacing on iOS 26 and macOS 26. Delete the old **QR VCard Share** first, then add the new one. Your
profiles and settings are kept.

## Building from source

The shortcut is written in [Cherri](https://cherrilang.org), a language that compiles to Apple
Shortcuts, plus a few fixes to Cherri kept here as patches. See
[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for building, testing and how it works.

## License

[MIT](LICENSE), except the Cherri patches in [patches/cherri/](patches/cherri/), which are GPL-2.0 like
Cherri itself.
