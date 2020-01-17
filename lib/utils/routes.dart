import 'package:vk_parse/ui/MusicList.dart';
import 'package:vk_parse/ui/Account.dart';
import 'package:vk_parse/ui/FriendList.dart';
import 'package:vk_parse/ui/Login.dart';

switchRoutes(player, {int route, bool offline, user}) {
  offline = offline != null ? offline : false;
  if (offline) {
    return MusicList(player, offline);
  }
  switch (route) {
    case 1:
      return MusicList(player, offline);
      break;
    case 2:
      return Account();
    case 3:
      return FriendList();
      break;
  }
  return Login(player);
}
