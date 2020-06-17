const _ = require("lodash/fp");
const winston = require("winston");

module.exports = {
  getEnv: (envName, defaultValue = undefined) =>
    _.getOr(defaultValue, envName)(process.env),

  getLogger: (verbose = false) => {
    return winston.createLogger({
      level: verbose ? "debug" : "info",
      format: winston.format.cli(),
      transports: [new winston.transports.Console()],
    });
  },
};
