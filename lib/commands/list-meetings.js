const BBB = require("../BBB");
const { getLogger } = require("../command-helpers");
const _ = require("lodash/fp");

module.exports = {
  name: "list-meetings",

  description: "List meetings currently running on BBB",

  handler: (argv) => {
    const logger = getLogger(argv.verbose);
    const bbbClient = new BBB(argv.u, argv.s);

    bbbClient
      .getMeetings()
      .then((meetings) => {
        if (meetings.length === 0) {
          logger.info("No meeting running on the BBB server");
          return;
        }
        logger.info("Currently running meetings:");
        for (const meeting of meetings) {
          logger.info(
            ` - ${meeting.meetingID} (${meeting.meetingName}) – participants : ${meeting.participantCount}`
          );
          const attendees = [].concat(_.get("attendees.attendee")(meeting));
          if (attendees.length > 0) {
            const attendeesNames = _.map("fullName")(attendees);
            logger.debug(`   [${attendeesNames.join(", ")}]`);
          }
        }
      })
      .catch(logger.error);
  },
};
