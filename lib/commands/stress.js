const { getEnv, getLogger } = require("../command-helpers");
const BBB = require("../BBB");
const _ = require("lodash/fp");
const stressTest = require("../stress-test");

const DEFAULT_BBB_TEST_DURATION = 60;
const DEFAULT_BBB_CLIENTS_WEBCAM = 1;
const DEFAULT_BBB_CLIENTS_MIC = 1;
const DEFAULT_BBB_CLIENTS_LISTEN_ONLY = 2;

module.exports = {
  name: "stress [meeting] [options]",
  description: "start the stress test",
  options: (yargs) => {
    yargs
      .option("webcams", {
        alias: "w",
        type: "number",
        description: "Number of clients to connect with an active webcam",
      })
      .positional("meeting", {
        description: "The meeting ID",
        type: "string",
      })
      .option("microphones", {
        alias: "m",
        type: "number",
        description: "Number of clients to connect with an active microphone",
      })
      .option("listening", {
        alias: "l",
        type: "number",
        description: "Number of clients to connect in listen-only mode",
      })
      .option("duration", {
        alias: "d",
        type: "number",
        description:
          "Duration of the stress test in seconds (after all clients are connected)",
      })
      .default("meeting", getEnv("BBB_MEETING_ID"))
      .default(
        "d",
        Number(getEnv("BBB_TEST_DURATION", DEFAULT_BBB_TEST_DURATION))
      )
      .default(
        "w",
        Number(getEnv("BBB_CLIENTS_WEBCAM", DEFAULT_BBB_CLIENTS_WEBCAM))
      )
      .default("m", Number(getEnv("BBB_CLIENTS_MIC", DEFAULT_BBB_CLIENTS_MIC)))
      .default(
        "l",
        Number(
          getEnv("BBB_CLIENTS_LISTEN_ONLY", DEFAULT_BBB_CLIENTS_LISTEN_ONLY)
        )
      )
      .demandOption("meeting");
  },

  handler: (argv) => {
    const logger = getLogger(argv.verbose);
    const bbbClient = new BBB(argv.u, argv.s);
    logger.info(`Starting stress test on meeting ${argv.meeting}`);
    logger.info("Test parameters :");
    logger.info(` - webcams : ${argv.webcams}`);
    logger.info(` - microphones : ${argv.microphones}`);
    logger.info(` - listening : ${argv.listening}`);
    logger.info(` - duration : ${argv.duration}s`);

    stressTest
      .start(
        bbbClient,
        logger,
        argv.meeting,
        argv.duration,
        argv.webcams,
        argv.microphones,
        argv.listening
      )
      .catch(console.error);
  },
};
