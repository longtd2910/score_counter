// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Bộ Đếm Điểm';

  @override
  String get settings => 'Cài Đặt';

  @override
  String get gameMode => 'Chế Độ Chơi';

  @override
  String get selectOrCreateGameMode => 'Chọn hoặc tạo chế độ chơi';

  @override
  String get viewSavedGames => 'Xem Trận Đã Lưu';

  @override
  String get seePreviouslySavedGames => 'Xem các trận đấu đã lưu trước đó';

  @override
  String get viewGameHistory => 'Xem Lịch Sử Trận';

  @override
  String get seeActionsHistoryLog => 'Xem nhật ký lịch sử hành động';

  @override
  String get keepScreenAwake => 'Giữ Màn Hình Sáng';

  @override
  String get preventScreenFromTurningOff => 'Ngăn màn hình tắt';

  @override
  String get language => 'Ngôn Ngữ';

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';

  @override
  String get systemDefault => 'Mặc Định Hệ Thống';

  @override
  String get cancel => 'Hủy';

  @override
  String get history => 'Lịch Sử';

  @override
  String get savedGames => 'Trận Đã Lưu';

  @override
  String get gameDetails => 'Chi Tiết Trận';

  @override
  String get chooseGameMode => 'Chọn Chế Độ Chơi';

  @override
  String get createNewGameMode => 'Tạo Chế Độ Chơi Mới';

  @override
  String get scoreCounter => 'Bộ Đếm Điểm';

  @override
  String get noSavedGamesYet => 'Chưa có trận đấu nào được lưu';

  @override
  String get deleteSavedGames => 'Xóa Trận Đã Lưu';

  @override
  String get deleteConfirmSingle =>
      'Bạn có chắc chắn muốn xóa trận đấu đã lưu này? Hành động này không thể hoàn tác.';

  @override
  String deleteConfirmMultiple(int count) {
    return 'Bạn có chắc chắn muốn xóa $count trận đấu đã lưu này? Hành động này không thể hoàn tác.';
  }

  @override
  String get delete => 'Xóa';
}
