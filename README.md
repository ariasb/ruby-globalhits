# Global Hits Ruby Exercise

This is an automation framework for Android mobile applications using Appium, Ruby, RSpec, and YAML for configuration.

## Table of Contents
- [About](#about)
- [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## About

This project provides automated tests for Android mobile applications. Using Appium for mobile interaction, Ruby as the programming language, RSpec as a BDD for structure and running testcases, YAML for managing  configurations. and there is nothing to manage reports, because i didnt  integrated it, but wanted to use report builder.


## Getting Started

This section guides other developers on how to get your project running locally.

### Prerequisites

List of software and tools you need to have installed:

- Git: For version control.
- Ruby: Version 3.0 or higher (ensure it's added to your system's PATH).
- Bundler: Ruby's dependency manager. Install with gem install bundler.
- Node.js and npm: Required for Appium.
- Appium Server: The core Appium server. Install: npm install -g appium.
- (Opcional)Appium Doctor: A utility to check Appium's dependencies. Install: npm install -g appium-doctor.
- Android SDK (with platform-tools): For Android development and automation (ADB, emulators).
- Ensure adb is in your system's PATH.
- An Android emulator: Configured and running.


### Installation

Steps to clone the repository and set up the project:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/ariasb/GlobalHits-Ruby.git
    ```

2.  **Navigate to the project directory:**
    ```bash
    cd ruby-globalhits #depending  onthe directory you downloaded it to
    ```

3.  **Install Ruby Gems (Dependencies):**
    ```bash
    bundle install
    ```
    This command will install all the necessary Ruby gems (like appium_lib, rspec, selenium-webdriver, yaml) as defined in your Gemfile.
	
4.  **Verify Appium Setup (Optional but Recommended):**
    ```bash
    appium-doctor
    ```
	
5.  **Start the Appium Server:**
	Open a new terminal window and start the Appium server.(cmd worked for me  because  powershell wanted  higher permissions) Keep this window open during test execution.
    ```bash
    appium-doctor
    ```
6.  **Start the Emulator:**
	Open another new terminal window and start the configured device with your created avd.(again i used cmd instead of powershell) Keep this window open during test execution as well.
    ```bash
    emulator -avd <nameOfYourDevice>
    ```

## Usage

To run the automated tests, ensure your Android emulator/device is running and the Appium server is started.

Then, execute the RSpec test suite from your project's root directory:

```bash
bundle exec rspec spec/tests/search_spec.rb
```
The tests are configured to automatically manage the application's lifecycle (terminate and activate) before each test run, ensuring a clean state.