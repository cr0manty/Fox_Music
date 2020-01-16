import 'package:vk_parse/ui/MusicList.dart';
import 'package:vk_parse/ui/Account.dart';
import 'package:vk_parse/ui/FriendList.dart';
import 'package:vk_parse/ui/Login.dart';

switchRoutes(player, {int route, bool offline, user}) {
  if (offline != null && offline) {
    return MusicList(player);
  }
  switch (route) {
    case 1:
      return MusicList(player);
      break;
    case 2:
      return Account();
    case 3:
      return FriendList();
      break;
  }
  return Login(player);
}

