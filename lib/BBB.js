const bbb = require("bigbluebutton-js");
const _ = require("lodash/fp");

class BBB {
  constructor(url, secret) {
    this.url = url;
    this.secret = secret;
    this.api = bbb.api(url, secret);
  }

  async bbbApiQuery(url) {
    const response = await bbb.http(url);
    if (response.returncode !== "SUCCESS") {
      return Promise.reject(`${response.messageKey} : ${response.message}`);
    }
    return Promise.resolve(response);
  }

  async getMeetings() {
    return (
      this.bbbApiQuery(this.api.monitoring.getMeetings())
        .then(_.getOr([], "meetings.meeting"))
        // The returned value can be a single element or an array, so we convert it to an array in all cases
        .then((meetings) => [].concat(meetings))
    );
  }

  async getMeetingInfo(meetingId) {
    return this.bbbApiQuery(this.api.monitoring.getMeetingInfo(meetingId));
  }

  async getAttendeePassword(meetingId) {
    return this.getMeetingInfo(meetingId).then(_.get("attendeePW"));
  }

  async getModeratorPassword(meetingId) {
    return this.getMeetingInfo(meetingId).then(_.get("moderatorPW"));
  }

  getJoinUrl(username, meetingID, password) {
    return this.api.administration.join(username, meetingID, password);
  }
}

module.exports = BBB;
