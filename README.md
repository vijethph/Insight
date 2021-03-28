[![Status](https://img.shields.io/badge/status-active-success.svg?style=flat-square&logo=flutter)](https://github.com/vijethph/Insight)
[![GitHub issues](https://img.shields.io/github/issues/vijethph/Insight?style=flat-square)](https://github.com/vijethph/Insight/issues)
[![Contributors](https://img.shields.io/github/contributors/vijethph/Insight?style=flat-square)](https://github.com/vijethph/Insight/graphs/contributors)
[![GitHub forks](https://img.shields.io/github/forks/vijethph/Insight?color=blue&style=flat-square)](https://github.com/vijethph/Insight/network)
[![GitHub stars](https://img.shields.io/github/stars/vijethph/Insight?color=yellow&style=flat-square)](https://github.com/vijethph/Insight/stargazers)
[![GitHub license](https://img.shields.io/github/license/vijethph/Insight?style=flat-square)](https://github.com/vijethph/Insight/blob/master/LICENSE)
[![made-with-flutter](https://img.shields.io/badge/made%20with-flutter-blue.svg?style=for-the-badge&labelColor=03045e&logo=flutter)](https://reactjs.org)
[![forthebadge](https://forthebadge.com/images/badges/built-by-developers.svg)](https://forthebadge.com)

<br />
<p align="center">
  <a href="https://github.com/vijethph/Insight">
    <img src="assets/eye.png" alt="Logo" width="120" height="120">
  </a>

  <h2 align="center">Insight</h2>

  <p align="center">
    A Flutter app for blind people.
    <br />
    <br />
    <a href="https://github.com/vijethph/Insight/issues">Report Bug</a>
    ·
    <a href="https://github.com/vijethph/Insight/issues">Request Feature</a>
  </p>
</p>

<!-- TABLE OF CONTENTS -->

## Table of Contents

- [About the Project](#about-the-project)
  - [Built With](#built-with)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)
- [Acknowledgements](#acknowledgements)

<!-- ABOUT THE PROJECT -->

## About The Project

This is a Flutter app that uses [Firebase ML vision](https://firebase.google.com/docs/ml), [Tensorflow Lite](https://www.tensorflow.org/lite), and in-built speech recogntion and text-to-speech capabilities to act like a third eye for blind people. It uses Firebase ML vision to detect human faces, and Tensorflow Lite model implementations of [MobileFaceNets]() and [SSD MobileNetV2](https://arxiv.org/abs/1801.04381) to perform face recognition and object detection respectively. The blind user can authenticate with fingerprint, issue voice commands to perform face recognition and object detection. The app responds appropriately via voice output for every command issued. The blind user can use this app to detect and save human faces, and detect objects in front of him/her.

### Built With

This project is entirely built with the following components and languages:

- [Flutter](https://flutter.dev/)
- [Firebase ML vision](https://firebase.google.com/docs/ml)
- [Tensorflow Lite](https://www.tensorflow.org/lite)
- [MobileFaceNets](https://arxiv.org/abs/1804.07573)
- [SSD MobileNetV2](https://arxiv.org/abs/1801.04381)

<!-- GETTING STARTED -->

## Getting Started

You can download the pre-built apk file found in the `Releases` section. Follow these instructions in order to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Java Runtime Environment(JRE)>=8, Android SDK API level 28 or higher should be installed. Flutter and Dart SDKs should be installed. After installation, check Java version, and Flutter configuration using

```sh
java --version
flutter doctor
```

### Installation

1. Download or Clone the repo

```git
git clone https://github.com/vijethph/Insight.git
```

2. Open the downloaded project folder

```sh
cd Insight
```

3. Make sure Flutter executable is added to environment variables. Go to project root and execute the following command in console to get the required dependencies

```sh
flutter pub get
```

4. Connect your Android device to your desktop. Make sure it is properly connected by using

```sh
flutter devices
```

5. Install and run the app using

```sh
flutter run
```

<!-- USAGE EXAMPLES -->

## Usage

Once the app starts, authenticate yourself with fingerprint. Then, tap to issue voice commands like `recognize face` and `detect objects` to perform respective functionalities. In face recognition screen, double tap to change camera, and once human face is detected, long tap to save detected face. The name for detected face can be given with voice input by tapping onto screen.

<!-- CONTRIBUTING -->

## Contributing [![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat-square)](https://github.com/vijethph/Insight/pulls)

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<!-- LICENSE -->

## License

Distributed under the MIT License.

<!-- CONTACT -->

## Contact

Vijeth P H - [@vijethph](https://github.com/vijethph)

Sathya M - [@sathya5278](https://github.com/sathya5278)

Shashank Ashok Gadavi - [@Shashankgadavi](https://github.com/Shashankgadavi)

Sagar V - [@sagubantii1911](https://github.com/sagubantii1911)

Project Link: [https://github.com/vijethph/Insight](https://github.com/vijethph/Insight)

## Thank You!

[![forthebadge](https://forthebadge.com/images/badges/built-with-love.svg)](https://forthebadge.com)

If you like this project, please ⭐ this repo and share it with others 👍

<!-- ACKNOWLEDGEMENTS -->

## Acknowledgements

- [Flutter Docs](https://flutter.dev/docs)
- [Firebase ML Docs](https://firebase.google.com/docs)
- [Tensorflow Lite Docs](https://www.tensorflow.org/lite/guide)
- [MobileFaceNets](https://arxiv.org/abs/1804.07573)
- [SSD MobileNetV2](https://arxiv.org/abs/1801.04381)
