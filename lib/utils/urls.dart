const DOMAIN = 'redfoxproject.com';
const BASE_URL  = 'https://' + DOMAIN;
//const BASE_URL  = 'http://' + '10.0.2.2:8000';

const BASE_API_URL = '$BASE_URL/api';
const APP_VERSION_URL = '$BASE_API_URL/app-version/fox-music/';
const DEFAULT_PLAYER_IMAGE_URL = '$BASE_API_URL/media/player-default.jpg';

const AUTH_URL = '$BASE_API_URL/auth/';
const VK_AUTH_URL = AUTH_URL + 'vk/';
const REGISTRATION_URL = '$BASE_API_URL/reg/';
const AUTH_CHECK = '$BASE_API_URL/auth_check/';

const PROFILE_URL = '$BASE_API_URL/users/profile/';
const SEARCH_USER_URL = '$BASE_API_URL/users/search/';

const SONG_LIST_URL = '$BASE_API_URL/songs/info/';
const SONG_SEARCH_URL = '$BASE_API_URL/songs/search/';
const SONG_DELETE_URL = '$BASE_API_URL/songs/delete_song/';
const SONG_ADD_URL = '$BASE_API_URL/songs/add_song/';
const ADD_NEW_SONG_URL = '$BASE_API_URL/songs/add-new-song/';

const FRIEND_URL = '$BASE_API_URL/users/friends/';
const FRIEND_LIST_SONG_LIST_URL = '$BASE_API_URL/songs/friend-songs/';
