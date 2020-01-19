import 'package:vk_parse/ui/MusicList.dart';
import 'package:vk_parse/ui/Account.dart';
import 'package:vk_parse/ui/FriendList.dart';
import 'package:vk_parse/ui/Login.dart';

switchRoutes(player, {int route, bool offline, user}) {
  if (offline != null && offline) {
    return MusicList(player, user, offlineMode: offline);
  }
  switch (route) {
    case 1:
      return MusicList(player, user);
    case 2:
      return Account(player, user);
    case 3:
      return FriendList(player, user);
  }
  return Login(player);
}

