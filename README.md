# Doughnut

![dough CI CD](https://github.com/nerds-odd-e/doughnut/workflows/dough%20CI%20CD/badge.svg)

## About

Doughnut is a Personal Knowledge Management ([PKM](https://en.wikipedia.org/wiki/Personal_knowledge_management)) tool combining [zettelkasten](https://eugeneyan.com/writing/note-taking-zettelkasten/) style of knowledge capture with some features to enhance learning (spaced-repetition, smart reminders) and ability to share knowledge bits with other people (for buddy/team learning).

For more background info you can read:

- <https://www.lesswrong.com/tag/scholarship-and-learning>
- <https://en.m.wikipedia.org/wiki/Knowledge_Acquisition_and_Documentation_Structuring>


### Tech Stack
- [OpenJDK 11](https://openjdk.java.net/projects/jdk/11/)
- [Spring Boot](https://spring.io/projects/spring-boot)
- [Thymeleaf](https://www.thymeleaf.org/)
- [Gradle](https://gradle.org/)
- [Junit5](https://junit.org/junit5/)
- [Cypress](https://www.cypress.io/)
- [JavaScript](https://www.javascript.com)
- [Cucumber](https://cucumber.io/docs/guides/)  
- [Flyway](https://flywaydb.org)  
- [MariaDB](https://mariadb.org/)
- [Google Cloud](https://cloud.google.com/gcp/getting-started)
- [Traefik](https://traefik.io/)
- [Github Actions](https://docs.github.com/en/actions)
- [Nix](https://nixos.org/)  
- [git-secret](https://git-secret.io)

## Getting started

### 1. Install nix

Find instruction at nixos.org (multi-user installation).

#### For macOS:

```
 sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume
```

#### For Linux:

```
sh <(curl -L https://nixos.org/nix/install) --daemon
```

(NB: if the install script fails to add sourcing of `nix.sh` in `.bashrc` or `.profile`, you can do it manually `source /etc/profile.d/nix.sh`)

_Install `any-nix-shell` for using `fish` or `zsh` in nix-shell_

```
nix-env -i any-nix-shell -f https://github.com/NixOS/nixpkgs/archive/master.tar.gz
```

##### `fish`

Add the following to your _~/.config/fish/config.fish_.
Create it if it doesn't exist.

```
any-nix-shell fish --info-right | source
```

##### `zsh`

Add the following to your _~/.zshrc_.
Create it if it doesn't exist.

```
any-nix-shell zsh --info-right | source /dev/stdin
```

### 2. Setup and run doughnut for the first time

The default spring profile is 'test' unless you explicitly set it to 'dev'. Tip: Add `--args="--spring.profiles.active={profile}"` to gradle task command.

```bash
git clone $this_repo
cd doughnut
nix-shell --pure
# OR `nix-shell --pure --command "zsh"` if you want to drop down to zsh in nix-shell (uses your OS' ~/.zshrc)
nohup idea-community &
# open doughnut project in idea
# click import gradle project
# wait for deps resolution
# restore gradle wrapper if missing (still require OS gradle bin see [Missing GradleWrapperMain ClassNotFoundException](https://stackoverflow.com/questions/29805622/could-not-find-or-load-main-class-org-gradle-wrapper-gradlewrappermain))
gradle wrapper --gradle-version 6.7.1 --distribution-type all
backend/gradlew bootRun -p backend --args="--spring.profiles.active=dev"
# open localhost:8080 in your browser
```

### 3. Setup and run doughnut with migrations in 'test' profile

```bash
backend/gradlew -p backend bootRun --args='--spring.profiles.active=test'
```

### 4. Secrets via [git-secret](https://git-secret.io) and [GnuPG](https://www.devdungeon.com/content/gpg-tutorial)

#### Generate your local GnuPG key

- Generate your GnuPG key 4096 bits key using your odd-e.com email address with no-expiry (option 0 in dialog):
```
gpg --full-generate-key
```

- Export your GnuPG public key:

```
gpg --export --armor <your_email>@odd-e.com > <your_email>_public_gpg_key.gpg
```

- Email your GnuPG public key file <your_email>_public_gpg_key.gpg from above step and private message an existing git-secret collaborator

#### Add a new user's GnuPG public key to local dev machine key-ring for git-secret for team secrets collaboration

- Add public key to local GnuPG key-ring: `gpg --import <your_email>_public_gpg_key.gpg`
- Add user to git-secret managed list of users: `git secret tell <your_email>@odd-e.com`
- Re-encrypt all managed secret files: `git secret hide -d`

#### List who are list of users managed by git-secret and allowed to encrypt/decrypt those files

- Short list of user emails of managed users: `git secret whoknows`
- List of user emails with expiration info of managed users: `git secret whoknows -l`

#### Removes a user from list of git-secret managed users (e.g. user should no longer be allowed access to list of secrets)
```
git secret killperson <user_to_be_removed_email>@odd-e.com
```

#### Add a new file for git-secret to manage

- Remove sensitive file from git: `git rm --cached <the_secret_file>`
- Tell git-secret to manage the file (auto add to .gitignore and update stuff in .gitsecret dir): `git secret add <the_secret_file>`
- Encrypt the file (need to reveal and hide for changes in list of users in dough/secrets*public_keys dir*): `git secret hide`

#### View diff of git-secret managed files

- `git secret changes -p <your__gpg_passphrase>`

#### List all git-secret managed files

- `git secret list`

#### Remove a git-secret file from git-secret management (make sure you reveal/decrypt it before doing this!!!)

- Just remove file from git-secret management but leaves it on the filesystem: `git secret remove <your__no_longer_secret_file>`
- Remove an encrypted file from git-secret management and permanently delete it from filesystem (make sure you have revealed/decrypted the file): `git secret remove -c <your_no_longer_secret_file>`

#### Reveal all git-secret managed encrypted files

- Upon hitting `enter/return` for each decrypt command below, enter secret passphrase you used when you generated your GnuPG key-pair.
- Decrypt secrets to local filesystem: `git secret reveal`
- Decrypt secrets to stdout: `git secret cat`

### MariaDB UI Client - DBeaver (ONLY available to Linux users - Non-macOS)
```
nohup dbeaver &
```

### 5. Create gcloud compute instance

- [Install `Google Cloud SDK`](https://cloud.google.com/sdk/docs/install)
- [Create App Server in GCloud Compute](backend/scripts/create-gcloud-app-compute.sh)
- Login to gcloud sdk: `gcloud auth login`
- Check your login: `gcloud auth list`
- Set/Point to gcloud dough project: `gcloud config set project carbon-syntax-298809`
- Check you can see the project as login user: `gcloud config list`

### 6. Check gcloud compute instance startup logs

```
gcloud compute instances get-serial-port-output doughnut-app-instance --zone us-east1-b
```

### 7. End-to-End Test / Features / Cucumber / SbE / ATDD

We use cucumber + cypress + Java library to do end to end test.

#### Commands

| purpose                       | command                               |
| ----------------------------- | ------------------------------------- |
| run all e2e test              | `yarn test`                           |
| run cypress IDE               | `yarn cy:open`                        |
| start SUT (system under test) | `yarn sut` (Not needed for yarn test) |

#### Structure

| purpose          | location                            |
| ---------------- | ----------------------------------- |
| feature files    | `/cypress/integration/**`           |
| step definitions | `/cypress/support/step_definitions` |

#### How to

The Cypress+Cucumber tests are written in JavaScript.
