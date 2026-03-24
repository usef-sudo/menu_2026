import "package:flutter_test/flutter_test.dart";
import "package:menu_2026/features/branches/domain/entities/branch_entity.dart";
import "package:menu_2026/features/branches/domain/entities/branch_opening_hour.dart";

void main() {
  group("BranchEntity.isEffectivelyOpenNow", () {
    test("legacy openTime/closeTime same day", () {
      final BranchEntity b = BranchEntity(
        id: "1",
        restaurantId: "r",
        nameEn: "N",
        nameAr: "",
        address: "",
        latitude: 0,
        longitude: 0,
        isOpen: true,
        upVotes: 0,
        downVotes: 0,
        openTime: "09:00",
        closeTime: "17:00",
        openingHours: const <BranchOpeningHour>[],
      );
      final DateTime mid = DateTime(2026, 3, 24, 12, 0);
      expect(b.isEffectivelyOpenNow(mid), isTrue);
      final DateTime night = DateTime(2026, 3, 24, 20, 0);
      expect(b.isEffectivelyOpenNow(night), isFalse);
    });

    test("legacy close 00:00 means end of business day", () {
      final BranchEntity b = BranchEntity(
        id: "1",
        restaurantId: "r",
        nameEn: "N",
        nameAr: "",
        address: "",
        latitude: 0,
        longitude: 0,
        isOpen: true,
        upVotes: 0,
        downVotes: 0,
        openTime: "10:00",
        closeTime: "00:00",
        openingHours: const <BranchOpeningHour>[],
      );
      final DateTime noon = DateTime(2026, 3, 24, 12, 0);
      expect(b.isEffectivelyOpenNow(noon), isTrue);
    });

    test("weekly slot with seconds in time string", () {
      final BranchEntity b = BranchEntity(
        id: "1",
        restaurantId: "r",
        nameEn: "N",
        nameAr: "",
        address: "",
        latitude: 0,
        longitude: 0,
        isOpen: true,
        upVotes: 0,
        downVotes: 0,
        openingHours: <BranchOpeningHour>[
          BranchOpeningHour(
            id: "h1",
            dayOfWeek: 2,
            slotIndex: 0,
            openTime: "10:00:00",
            closeTime: "18:00:00",
            closesNextDay: false,
          ),
        ],
      );
      final DateTime tuesdayNoon = DateTime(2026, 3, 24, 12, 0);
      expect(tuesdayNoon.weekday, 2);
      expect(b.isEffectivelyOpenNow(tuesdayNoon), isTrue);
    });

    test("isOpen false forces closed even with hours", () {
      final BranchEntity b = BranchEntity(
        id: "1",
        restaurantId: "r",
        nameEn: "N",
        nameAr: "",
        address: "",
        latitude: 0,
        longitude: 0,
        isOpen: false,
        upVotes: 0,
        downVotes: 0,
        openTime: "00:00",
        closeTime: "23:59",
        openingHours: const <BranchOpeningHour>[],
      );
      expect(b.isEffectivelyOpenNow(DateTime(2026, 3, 24, 12, 0)), isFalse);
    });
  });
}
