Map<String, String> formatToken(token) {
  return {
      'Authorization': "Token $token",
    };
}
