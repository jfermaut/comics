dynamic handleError(int statusCode) {
  switch (statusCode) {
    case 100:
      throw Exception('Clé API invalide.');
    case 101:
      throw Exception('Objet introuvable.');
    case 102:
      throw Exception('Erreur de format d\'URL.');
    case 103:
      throw Exception('Erreur de requête JSONP.');
    case 104:
      throw Exception('Erreur de filtre.');
    case 105:
      throw Exception('Accès refusé.');
    default:
      throw Exception('Erreur inconnue. Code de statut : $statusCode');
  }
}