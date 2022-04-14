import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String appName = 'Medication Reminder';
const String appLogo = 'images/ic_launcher.png';

const String developerName = 'Md. Imam Hossain';
const String designerName = 'Md. Imam Hossain';

const String feedbackMail = 'mailto:imamagun94@gmail.com';
const String contactMail = 'mailto:imamagun94@gmail.com';

const String appLink =
    'https://play.google.com/store/apps/details?id=com.masleap.medication_reminder';
const String storeLink =
    'https://play.google.com/store/apps/developer?id=NewAgeDevs';
const String privacyPolicyUrl = '';

// Test ads unit id Google
// const String idBanner = "ca-app-pub-3940256099942544/6300978111";
// const String idInterstitial = "ca-app-pub-3940256099942544/1033173712";

// Real ads unit id Google
// const String idBanner = "ca-app-pub-4061500537427923/9291376593";
// const String idInterstitial = "ca-app-pub-4061500537427923/3272763158";

const scaffoldBackgroundLight = Color(0xFFF6F7F8);
const scaffoldBackgroundDark = Color(0xFF212230);
const backgroundLight = Color(0xFFFFFFFF);
const backgroundDark = Color(0xFF323647);
const colorButtonDisable = Color(0xFFB1BCD0);

const colorOnPrimary = Color(0xFF010A1C);
const colorSecondary = Color(0xFFFF2323);
const colorOnSecondary = Color(0xFFFFFFFF);
const colorOnPrimaryDark = Color(0xFFF8F8F8);
const colorSecondaryDark = Color(0xFFFF2323);
const colorOnSecondaryDark = Color(0xFFF8F8F8);

SystemUiOverlayStyle mainPageSystemOverlay(Brightness brightness) =>
    SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarColor: brightness == Brightness.dark
          ? scaffoldBackgroundLight
          : scaffoldBackgroundDark,
      systemNavigationBarIconBrightness: brightness,
      statusBarColor: brightness == Brightness.dark
          ? scaffoldBackgroundLight
          : scaffoldBackgroundDark,
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
    );

enum viewMode { list, grid }

// Assets path
const bandageSvg = 'assets/form/bandage.svg';
const bottleSvg = 'assets/form/bottle.svg';
const capsuleSvg = 'assets/form/capsule.svg';
const creamSvg = 'assets/form/cream.svg';
const dropsSvg = 'assets/form/drops.svg';
const injectionSvg = 'assets/form/injection.svg';
const powderSvg = 'assets/form/powder.svg';
const soapSvg = 'assets/form/soap.svg';
const spraySvg = 'assets/form/spray.svg';
const suppositorySvg = 'assets/form/suppository.svg';
const tabletsSvg = 'assets/form/tablets.svg';
const unknownSvg = 'assets/form/unknown.svg';


// Form possibility
class FormPossibility {
  static const bottle = [
    'suspension',
    'syrup',
    'solution',
    'emulsion',
    'liquid',
    'wash',
    'rub',
    'elixir'
  ];
  static const tablet = ['tablet', 'film'];
  static const capsule = 'cap';
  static const injection = ['injection', 'saline', 'vaccine', 'infusion', 'kit'];
  static const tube = ['gel', 'ointment', 'cream', 'paste', 'shampoo', 'lotion'];
  static const suppository = 'suppository';
  static const drops = 'drops';
  static const inhaler = ['inhalation', 'inhaler', 'spray'];
  static const powder = ['powder', 'saline'];
  static const bandage = ['bandage', 'patch'];
  static const soap = 'bar';
}


