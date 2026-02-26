// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Ankata';

  @override
  String get appSubtitle => 'Transport Intelligent au Burkina Faso';

  @override
  String get appDescription => 'Réservez vos trajets en ligne facilement et rapidement';

  @override
  String get search => 'Rechercher';

  @override
  String get origin => 'Départ';

  @override
  String get destination => 'Arrivée';

  @override
  String get date => 'Date';

  @override
  String get time => 'Heure';

  @override
  String get searchTrips => 'Rechercher des trajets';

  @override
  String get noResults => 'Aucun trajet trouvé';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get retry => 'Réessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get save => 'Enregistrer';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get companies => 'Compagnies';

  @override
  String get lines => 'Lignes';

  @override
  String get schedules => 'Horaires';

  @override
  String get bookings => 'Réservations';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get help => 'Aide';

  @override
  String get price => 'Prix';

  @override
  String get duration => 'Durée';

  @override
  String get distance => 'Distance';

  @override
  String get seats => 'Sièges';

  @override
  String get available => 'Disponible';

  @override
  String get soldOut => 'Complet';

  @override
  String get rating => 'Note';

  @override
  String get reviews => 'Avis';

  @override
  String get book => 'Réserver';

  @override
  String get bookingConfirmed => 'Réservation confirmée';

  @override
  String get bookingCancelled => 'Réservation annulée';

  @override
  String get bookingHistory => 'Historique de réservations';

  @override
  String get payment => 'Paiement';

  @override
  String get paymentMethod => 'Méthode de paiement';

  @override
  String get orangeMoney => 'Orange Money';

  @override
  String get moovMoney => 'Moov Money';

  @override
  String get yengaPay => 'Yenga Pay';

  @override
  String get cardPayment => 'Carte bancaire';

  @override
  String get wave => 'Wave';

  @override
  String get login => 'Connexion';

  @override
  String get logout => 'Déconnexion';

  @override
  String get signup => 'Inscription';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get phone => 'Téléphone';

  @override
  String get forgotPassword => 'Mot de passe oublié';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get otp => 'Code OTP';

  @override
  String get otpSent => 'Code OTP envoyé par SMS';

  @override
  String get otpExpired => 'Le code OTP a expiré';

  @override
  String get otpInvalid => 'Code OTP invalide';

  @override
  String get about => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get contact => 'Contact';

  @override
  String get website => 'Site web';

  @override
  String get facebook => 'Facebook';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Thème';

  @override
  String get notifications => 'Notifications';

  @override
  String get monday => 'Lundi';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get january => 'Janvier';

  @override
  String get february => 'Février';

  @override
  String get march => 'Mars';

  @override
  String get april => 'Avril';

  @override
  String get may => 'Mai';

  @override
  String get june => 'Juin';

  @override
  String get july => 'Juillet';

  @override
  String get august => 'Août';

  @override
  String get september => 'Septembre';

  @override
  String get october => 'Octobre';

  @override
  String get november => 'Novembre';

  @override
  String get december => 'Décembre';

  @override
  String get fcfa => 'FCFA';

  @override
  String get km => 'km';

  @override
  String get minute => 'minute';

  @override
  String get minutes => 'minutes';

  @override
  String get hour => 'heure';

  @override
  String get hours => 'heures';

  @override
  String welcome(String name) {
    return 'Bienvenue $name';
  }

  @override
  String tripPrice(int price) {
    return 'Prix du trajet: $price FCFA';
  }

  @override
  String departureTime(String time) {
    return 'Départ à $time';
  }

  @override
  String arrivalTime(String time) {
    return 'Arrivée à $time';
  }

  @override
  String tripDuration(String duration) {
    return 'Durée: $duration heures';
  }

  @override
  String get selectSeats => 'Select seats';

  @override
  String get seat => 'Seat';

  @override
  String get stops => 'Stops';

  @override
  String get stop => 'Stop';

  @override
  String get passengerInfo => 'Passenger Information';

  @override
  String get enterPassengerInfo => 'Enter passenger information';

  @override
  String get passengerName => 'Passenger Name';

  @override
  String get passengerPhone => 'Passenger Phone';

  @override
  String get selectTrip => 'Select a trip';

  @override
  String get paymentSummary => 'Payment Summary';

  @override
  String get ticketPrice => 'Ticket Price';

  @override
  String get serviceFee => 'Service Fee';

  @override
  String get seatSurcharge => 'Seat Surcharge';

  @override
  String get total => 'Total';

  @override
  String get totalPrice => 'Total to Pay';

  @override
  String get pay => 'Pay';

  @override
  String get booking => 'Booking';

  @override
  String get bookingSuccessful => 'Booking Confirmed';

  @override
  String get bookingCode => 'Booking Code';

  @override
  String get bookingDate => 'Booking Date';

  @override
  String get qrCode => 'QR Code';

  @override
  String get download => 'Download';

  @override
  String get share => 'Share';

  @override
  String get myBookings => 'My Bookings';

  @override
  String get upcomingTrips => 'Upcoming Trips';

  @override
  String get pastTrips => 'Past Trips';

  @override
  String get cancelBooking => 'Cancel Booking';

  @override
  String get favorite => 'Favorite';

  @override
  String get favorites => 'Favorites';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get sortBy => 'Sort By';

  @override
  String get sortByPrice => 'Price';

  @override
  String get sortByTime => 'Time';

  @override
  String get sortByDuration => 'Duration';

  @override
  String get sortByRating => 'Rating';

  @override
  String get filter => 'Filter';

  @override
  String get filters => 'Filters';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get apply => 'Apply';
}
