import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:vega_dashboard/enums/translated_user_role.dart";

import "../enums/coupon_item_price.dart";
import "../enums/seller_template.dart";
import "../strings.dart";

// Currency enum

extension LocaleSelectItem on Locale {
  SelectItem toSelectItem() => SelectItem(label: "core_language_$languageCode".tr(), value: languageCode);
  static Locale from(SelectItem item) => Locale(item.value);
  static Locale? fromOrNull(SelectItem? item) => item == null ? null : from(item);
}

extension LocalesSelectedItems on List<Locale> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
  static List<Locale> from(List<SelectItem> items) => items.map((e) => LocaleSelectItem.from(e)).toList();
  static List<Locale>? fromOrNull(List<SelectItem>? items) => items == null ? null : from(items);
}

extension CurrencySelectItem on Currency {
  SelectItem toSelectItem() => SelectItem(label: "$code ($symbol)", value: code);
  static Currency from(SelectItem item) => Currency.values.firstWhere((e) => e.code == item.value);
  static Currency? fromOrNull(SelectItem? item) => item == null ? null : from(item);
}

extension CurrencySelectedItems on List<Currency> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
  static List<Currency> from(List<SelectItem> items) => items.map((e) => CurrencySelectItem.from(e)).toList();
  static List<Currency>? fromOrNull(List<SelectItem>? items) => items == null ? null : from(items);
}

// Country enum

extension CountrySelectItem on Country {
  SelectItem toSelectItem() => SelectItem(label: localizedName, value: code);
}

extension CountriesSelectedItems on List<Country> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// ProgramType enum

extension ProgramTypeSelectItem on ProgramType {
  SelectItem toSelectItem() => SelectItem(label: localizedName, value: code.toString());
}

extension ProgramTypesSelectedItems on List<ProgramType> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// Coupon class

extension CouponSelectItem on Coupon {
  SelectItem toSelectItem() => SelectItem(label: name, value: couponId);
}

extension CouponsSelectedItems on List<Coupon> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// CouponType

extension CouponTypeSelectItem on CouponType {
  SelectItem toSelectItem() => SelectItem(label: localizedName, value: code.toString());
}

extension CouponTypesSelectedItems on List<CouponType> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// CouponItemPrice enum

extension CouponItemPriceSelectItem on CouponItemPrice {
  SelectItem toSelectItem() => SelectItem(label: localizedName, value: toString());
}

extension CouponItemPricesSelectedItems on List<CouponItemPrice> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// Program class

extension ProgramSelectItem on Program {
  SelectItem toSelectItem() => SelectItem(label: name, value: programId);
}

extension ProgramsSelectedItems on List<Program> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// Card class

extension CardSelectItem on Card {
  SelectItem toSelectItem() => SelectItem(label: name, value: cardId);
}

extension CardSelectObject on Card {
  SelectObject<Card> toSelectObject() => SelectObject<Card>(label: name, object: this);
}

extension CardsSelectedItems on List<Card> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

extension CardsSelectedObjects on List<Card> {
  List<SelectObject<Card>> toSelectObjects() => map((e) => e.toSelectObject()).toList();
}

// LoyaltyMode enum

extension LoyaltyModeSelectItem on LoyaltyMode {
  SelectItem toSelectItem() => SelectItem(label: localizedName, value: code.toString());
}

extension LoyaltyModesSelectedItems on List<LoyaltyMode> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// Reservation class

extension ReservationSelectItem on Reservation {
  SelectItem toSelectItem() => SelectItem(label: name, value: reservationId);
}

extension ReservationsSelectedItems on List<Reservation> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// ReservationSlot class

extension ReservationSlotSelectItem on ReservationSlot {
  SelectItem toSelectItem() => SelectItem(label: name, value: reservationSlotId);
}

extension ReservationSlotsSelectedItems on List<ReservationSlot> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// ClientCategory enum

extension ClientCategorySelectItem on ClientCategory {
  SelectItem toSelectItem() => SelectItem(label: localizedName, value: code.toString());
}

extension ClientSelectedItems on List<ClientCategory> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// UserRole enum

extension UserRoles on UserRole {
  SelectItem toSelectItem() => SelectItem(label: localizedName, value: code.toString());
}

extension UserRolesSelectedItems on List<UserRole> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// ClientPaymentProvider class

extension ClientPaymentProviders on ClientPaymentProvider {
  SelectItem toSelectItem() => SelectItem(label: name, value: clientPaymentProviderId);
}

extension ClientPaymentProviderSelectedItems on List<ClientPaymentProvider> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// Location

extension LocationSelectItem on Location {
  SelectItem toSelectItem() => SelectItem(label: name, value: locationId);
}

extension LocationsSelectedItems on List<Location> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

extension LocationTypeSelectItem on LocationType {
  SelectItem toSelectItem() => SelectItem(label: localizedName, value: code.toString());
}

extension LocationTypesSelectedItems on List<LocationType> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// PrintSize and PrintOrientation

extension PrintSizeSelectItem on PrintSize {
  static Map<PrintSize, String> printSizeMap = {
    PrintSize.a3: "A3",
    PrintSize.a4: "A4",
    PrintSize.a5: "A5",
    PrintSize.letter: LangKeys.printSizeLetter.tr(),
    PrintSize.legal: LangKeys.printSizeLegal.tr(),
    PrintSize.tabloid: LangKeys.printSizeTabloid.tr(),
  };

  SelectItem toSelectItem() => SelectItem(label: printSizeMap[this]!, value: code.toString());
}

extension PrintSizeSelectedItems on List<PrintSize> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

extension PrintOrientationSelectItem on PrintOrientation {
  static Map<PrintOrientation, String> printOrientationMap = {
    PrintOrientation.portrait: LangKeys.printOrientationPortrait.tr(),
    PrintOrientation.landscape: LangKeys.printOrientationLandscape.tr(),
  };

  SelectItem toSelectItem() => SelectItem(label: printOrientationMap[this]!, value: code.toString());
}

extension PrintOrientationSelectedItems on List<PrintOrientation> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// ProductSection class

extension ProductSectionSelectItem on ProductSection {
  SelectItem toSelectItem() => SelectItem(label: name, value: sectionId);
}

extension ProductSectionsSelectedItems on List<ProductSection> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// ProductItem class

extension ProductItemSelectItem on ProductItem {
  SelectItem toSelectItem() => SelectItem(label: name, value: itemId);
}

extension ProductItemsSelectedItems on List<ProductItem> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// ProductOfferType enum

extension ProductOfferTypeSelectItem on ProductOfferType {
  SelectItem toSelectItem() => SelectItem(label: localizedName, value: code.toString());
}

extension ProductOfferTypeSelectedItems on List<ProductOfferType> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// ProductItemModificationType enum

extension ProductItemModificationTypeSelectItem on ProductItemModificationType {
  SelectItem toSelectItem() => SelectItem(label: localizedName, value: code.toString());
}

extension ProductItemModificationTypeSelectedItems on List<ProductItemModificationType> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// ProductItemOptionPricing enum

extension ProductItemOptionPricingSelectItem on ProductItemOptionPricing {
  SelectItem toSelectItem() => SelectItem(label: localizedName, value: code.toString());
}

extension ProductItemOptionPricingSelectedItems on List<ProductItemOptionPricing> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// SellerTemplate enum

extension SellerTemplateSelectItem on SellerTemplate {
  SelectItem toSelectItem() => SelectItem(label: localizedName, value: name);
}

extension SellerTemplateSelectedItems on List<SellerTemplate> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

// eof
