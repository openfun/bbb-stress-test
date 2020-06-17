# A stress testing tool for BigBlueButton

## Overview

This is a stress testing tool for [BigBlueButton](https://bigbluebutton.org/).

It simulates client activity in a BBB conference thanks to [Puppeteer](https://pptr.dev/).

## Getting Started

### Preparation

1) Clone this repository

2) Run `make bootstrap`

3) Update the generated `.env` file to specify `BBB_URL` and `BBB_SECRET`. \
You can get these values by running `bbb-conf --secret` on your BBB server.

### Ready to launch your test?

1) Manually start a meeting on your BBB server.

2) Get the meeting ID by running `make list-meetings`

3) Update your `.env` file to set the following variables :
   - `BBB_MEETING_ID` : the meeting ID
   - `BBB_CLIENTS_LISTEN_ONLY`: the number of simultaneous clients to connect in "Listen only" mode
   - `BBB_CLIENTS_MIC` : the number of simultaneous clients to connect with an active microphone
   - `BBB_CLIENTS_WEBCAM` : the number of simultaneous clients to connect with an active webcam and microphone
   - `BBB_TEST_DURATION` : the duration of the test in seconds

4) Run `make stress` to launch the test suite

## Contributing

This project is intended to be community-driven, so please, do not hesitate to
get in touch if you have any question related to our implementation or design
decisions.

We try to raise our code quality standards and expect contributors to follow
the recommandations from our
[handbook](https://openfun.gitbooks.io/handbook/content).

## License

This work is released under the MIT License (see [LICENSE](./LICENSE)).
