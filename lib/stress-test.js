const puppeteer = require("puppeteer");
const _ = require("lodash/fp");
const username = require("./username");

const initClient = async (
  browser,
  logger,
  joinUrl,
  webcam = false,
  microphone = false
) => {
  const page = await browser.newPage();
  await page.goto(joinUrl);
  const audioAction = microphone ? "Microphone" : "Listen only";
  logger.debug(`waiting for audio prompt ([aria-label="${audioAction}"])`);
  await page.waitForSelector(`[aria-label="${audioAction}"]`);
  logger.debug(`click on ${audioAction}`);
  await page.click(`[aria-label="${audioAction}"]`);
  if (microphone) {
    logger.debug("waiting for the echo test dialog");
    try {
      await page.waitForSelector(`[aria-label="Echo is audible"]`);
      logger.debug(
        'echo test dialog detected. clicking on "Echo is audible" button.'
      );
      await page.click(`[aria-label="Echo is audible"]`);
    } catch (err) {
      logger.debug(
        "unable to detect the echo test dialog. Maybe echo test is disabled."
      );
    }
  }
  await page.waitForSelector(".ReactModal__Overlay", { hidden: true });
  if (microphone) {
    logger.debug("Ensure that we are not muted...");
    // Wait for the toolbar to appear
    await page.waitForSelector('[aria-label="Mute"],[aria-label="Unmute"]');
    // If we are muted, click on Unmute
    const unmuteButton = await page.$('[aria-label="Unmute"]');
    if (unmuteButton !== null) {
      logger.debug("clicking on unmute button");
      await unmuteButton.click();
    }
  }
  if (webcam) {
    await page.waitForSelector('[aria-label="Share webcam"]');
    await page.click('[aria-label="Share webcam"]');
    logger.debug("clicked on sharing webcam");
    await new Promise((resolve) => setTimeout(resolve, 2000));
    await page.waitForSelector("#setCam > option");
    await page.waitForSelector('[aria-label="Start sharing"]');
    logger.debug("clicking on start sharing");
    await page.click('[aria-label="Start sharing"]');
  }
  return Promise.resolve(page);
};

const generateClientConfig = (webcam = false, microphone = false) => {
  return {
    username: username.getRandom(),
    webcam,
    microphone,
  };
};

async function start(
  bbbClient,
  logger,
  meetingID,
  testDuration,
  clientWithCamera,
  clientWithMicrophone,
  clientListening
) {
  const [browser, meetingPassword] = await Promise.all([
    puppeteer.launch({
      executablePath: "google-chrome-unstable",
      args: [
        "--use-fake-device-for-media-stream",
        "--use-fake-ui-for-media-stream",
        "--mute-audio",
      ],
    }),
    bbbClient.getModeratorPassword(meetingID),
  ]);

  const clientsConfig = [
    ...[...Array(clientWithCamera)].map(() => generateClientConfig(true, true)),
    ...[...Array(clientWithMicrophone)].map(() =>
      generateClientConfig(false, true)
    ),
    ...[...Array(clientListening)].map(() =>
      generateClientConfig(false, false)
    ),
  ];

  for (let idx = 0; idx < clientsConfig.length; idx++) {
    logger.info(`${clientsConfig[idx].username} join the conference`);
    await initClient(
      browser,
      logger,
      bbbClient.getJoinUrl(
        clientsConfig[idx].username,
        meetingID,
        meetingPassword
      ),
      clientsConfig[idx].webcam,
      clientsConfig[idx].microphone
    ).catch((err) => {
      logger.error(
        `Unable to initialize client ${clientsConfig[idx].username} : ${err}`
      );
      Promise.resolve(null);
    });
  }

  logger.info("All user joined the conference");
  logger.info(`Sleeping ${testDuration}s`);
  await new Promise((resolve) => setTimeout(resolve, testDuration * 1000));
  logger.info("Test finished");
  return browser.close();
}

module.exports = {
  start,
};
