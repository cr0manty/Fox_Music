import 'package:fox_music/models/user.dart';

enum RelationshipStatus { FRIEND, UNKNOWN, FOLLOW, FOLLOWING, BLOCK }

class Relationship {
  User user;
  RelationshipStatus status;

  Relationship(this.user, {int statusId}) {
    switchStatus(statusId ?? -1);
  }

  switchStatus(int statusId) {
    switch (statusId) {
      case 0:
        status = RelationshipStatus.FOLLOW;
        break;
      case 1:
        status = RelationshipStatus.FOLLOWING;
        break;
      case 2:
        status = RelationshipStatus.FRIEND;
        break;
      case 3:
        status = RelationshipStatus.BLOCK;
        break;
      default:
        status = RelationshipStatus.UNKNOWN;
    }
  }

  buttonName() {
    switch (status) {
      case RelationshipStatus.FRIEND:
        return 'Delete';
      case RelationshipStatus.UNKNOWN:
        return 'Follow';
      case RelationshipStatus.FOLLOW:
        return 'Add';
      case RelationshipStatus.FOLLOWING:
        return 'Unfollow';
      case RelationshipStatus.BLOCK:
        return 'Unblock';
    }
  }

  sendRequest() {

  }

  sendBlock() {

  }
}
