import 'package:flutter/material.dart';
import 'generated_l10n/app_localizations.dart';

extension Localization on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  
  String get appTitle => l10n.appTitle;
  String get search => l10n.search;
  String get origin => l10n.origin;
  String get destination => l10n.destination;
  String get date => l10n.date;
  String get time => l10n.time;
  String get searchTrips => l10n.searchTrips;
  String get noResults => l10n.noResults;
  String get loading => l10n.loading;
  String get error => l10n.error;
  String get retry => l10n.retry;
  String get cancel => l10n.cancel;
  String get confirm => l10n.confirm;
  String get save => l10n.save;
  String get edit => l10n.edit;
  String get delete => l10n.delete;
  String get login => l10n.login;
  String get logout => l10n.logout;
  String get signup => l10n.signup;
  String get email => l10n.email;
  String get password => l10n.password;
  String get phone => l10n.phone;
  String get payment => l10n.payment;
  String get book => l10n.book;
  String get price => l10n.price;
  String get duration => l10n.duration;
  String get seats => l10n.seats;
  String get available => l10n.available;
  String get soldOut => l10n.soldOut;
  String get rating => l10n.rating;
  String get reviews => l10n.reviews;
  String get profile => l10n.profile;
  String get settings => l10n.settings;
  String get help => l10n.help;
  String get language => l10n.language;
  String get theme => l10n.theme;
  String get about => l10n.about;
  String get version => l10n.version;
}
