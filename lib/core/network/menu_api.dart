import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/api_envelope.dart";
import "package:menu_2026/core/network/dio_client.dart";
import "package:menu_2026/features/admin/data/admin_user_dto.dart";
import "package:menu_2026/features/admin/data/area_dto.dart";
import "package:menu_2026/features/auth/data/models/login_response_dto.dart";
import "package:menu_2026/features/branches/data/models/branch_dto.dart";
import "package:menu_2026/features/categories/data/models/category_dto.dart";
import "package:menu_2026/features/facilities/data/models/facility_dto.dart";
import "package:menu_2026/features/offers/data/models/offer_dto.dart";
import "package:menu_2026/features/restaurants/data/models/restaurant_dto.dart";
import "package:menu_2026/features/restaurants/domain/entities/menu_image_entity.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_photo_entity.dart";
import "package:menu_2026/features/reviews/domain/entities/review_entity.dart";

class MenuApi {
  MenuApi(this._dio);
  final Dio _dio;

  Future<List<CategoryDto>> getCategories({bool activeOnly = true}) async {
    final response = await _dio.get<dynamic>(
      "/categories",
      queryParameters: <String, dynamic>{
        "active": activeOnly ? "true" : "false",
        "limit": 200,
      },
    );
    final envelope = ApiEnvelope.fromDynamic<List<CategoryDto>>(response.data, (
      dynamic data,
    ) {
      final list = data as List<dynamic>;
      return list
          .map(
            (dynamic item) =>
                CategoryDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
    });
    return envelope.data;
  }

  CategoryDto _categoryDtoFromEnvelopeData(dynamic body) {
    dynamic data = body;
    if (body is Map<String, dynamic> && body.containsKey("data")) {
      data = body["data"];
    }
    return CategoryDto.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// Admin only (requires JWT with role admin).
  Future<CategoryDto> adminCreateCategory({
    required String nameEn,
    required String nameAr,
    String? descriptionEn,
    String? descriptionAr,
    String? icon,
    int displayOrder = 0,
    bool isActive = true,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      "/categories",
      data: <String, dynamic>{
        "nameEn": nameEn,
        "nameAr": nameAr,
        if (descriptionEn != null && descriptionEn.isNotEmpty)
          "descriptionEn": descriptionEn,
        if (descriptionAr != null && descriptionAr.isNotEmpty)
          "descriptionAr": descriptionAr,
        if (icon != null && icon.isNotEmpty) "icon": icon,
        "displayOrder": displayOrder,
        "isActive": isActive,
      },
    );
    return _categoryDtoFromEnvelopeData(response.data);
  }

  /// Admin only.
  Future<CategoryDto> adminUpdateCategory(
    String id, {
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
    String? icon,
    int? displayOrder,
    bool? isActive,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{};
    if (nameEn != null) payload["nameEn"] = nameEn;
    if (nameAr != null) payload["nameAr"] = nameAr;
    if (descriptionEn != null) payload["descriptionEn"] = descriptionEn;
    if (descriptionAr != null) payload["descriptionAr"] = descriptionAr;
    if (icon != null) payload["icon"] = icon;
    if (displayOrder != null) payload["displayOrder"] = displayOrder;
    if (isActive != null) payload["isActive"] = isActive;
    final Response<dynamic> response = await _dio.put<dynamic>(
      "/categories/$id",
      data: payload,
    );
    return _categoryDtoFromEnvelopeData(response.data);
  }

  /// Admin only.
  Future<void> adminDeleteCategory(String id) async {
    await _dio.delete<dynamic>("/categories/$id");
  }

  /// Admin only — body `categoryIds` in display order.
  Future<void> adminReorderCategories(List<String> categoryIds) async {
    await _dio.post<dynamic>(
      "/categories/reorder",
      data: <String, dynamic>{"categoryIds": categoryIds},
    );
  }

  CategoryDto _categoryFromWithImageResponse(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey("data")) {
      return CategoryDto.fromJson(
        Map<String, dynamic>.from(data["data"]! as Map<dynamic, dynamic>),
      );
    }
    if (data is Map<String, dynamic>) {
      return CategoryDto.fromJson(data);
    }
    throw StateError("Unexpected category response");
  }

  /// Admin only — multipart; `imageBytes` required.
  Future<CategoryDto> adminCreateCategoryWithImage({
    required String nameEn,
    required String nameAr,
    required List<int> imageBytes,
    required String filename,
    String? descriptionEn,
    String? descriptionAr,
    String? icon,
    int displayOrder = 0,
    bool isActive = true,
  }) async {
    final FormData form = FormData.fromMap(<String, dynamic>{
      "nameEn": nameEn,
      "nameAr": nameAr,
      "displayOrder": displayOrder.toString(),
      "isActive": isActive.toString(),
      if (descriptionEn != null && descriptionEn.isNotEmpty)
        "descriptionEn": descriptionEn,
      if (descriptionAr != null && descriptionAr.isNotEmpty)
        "descriptionAr": descriptionAr,
      if (icon != null && icon.isNotEmpty) "icon": icon,
      "image": MultipartFile.fromBytes(imageBytes, filename: filename),
    });
    final Response<dynamic> response = await _dio.post<dynamic>(
      "/categories/with-image",
      data: form,
    );
    return _categoryFromWithImageResponse(response.data);
  }

  /// Admin only — optional new image bytes.
  Future<CategoryDto> adminUpdateCategoryWithImage(
    String id, {
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
    String? icon,
    int? displayOrder,
    bool? isActive,
    List<int>? imageBytes,
    String? imageFilename,
  }) async {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (nameEn != null) map["nameEn"] = nameEn;
    if (nameAr != null) map["nameAr"] = nameAr;
    if (descriptionEn != null) map["descriptionEn"] = descriptionEn;
    if (descriptionAr != null) map["descriptionAr"] = descriptionAr;
    if (icon != null) map["icon"] = icon;
    if (displayOrder != null) map["displayOrder"] = displayOrder.toString();
    if (isActive != null) map["isActive"] = isActive.toString();
    if (imageBytes != null && imageBytes.isNotEmpty) {
      map["image"] = MultipartFile.fromBytes(
        imageBytes,
        filename: imageFilename ?? "image.jpg",
      );
    }
    final FormData form = FormData.fromMap(map);
    final Response<dynamic> response = await _dio.put<dynamic>(
      "/categories/$id/with-image",
      data: form,
    );
    return _categoryFromWithImageResponse(response.data);
  }

  // —— Facilities (admin writes) ——
  Future<FacilityDto> adminCreateFacility({
    required String nameEn,
    required String nameAr,
    String? icon,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      "/facilities",
      data: <String, dynamic>{
        "nameEn": nameEn,
        "nameAr": nameAr,
        if (icon != null && icon.isNotEmpty) "icon": icon,
      },
    );
    return FacilityDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FacilityDto> adminUpdateFacility(
    String id, {
    String? nameEn,
    String? nameAr,
    String? icon,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{};
    if (nameEn != null) body["nameEn"] = nameEn;
    if (nameAr != null) body["nameAr"] = nameAr;
    if (icon != null) body["icon"] = icon;
    final Response<dynamic> response =
        await _dio.put<dynamic>("/facilities/$id", data: body);
    return FacilityDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> adminDeleteFacility(String id) async {
    await _dio.delete<dynamic>("/facilities/$id");
  }

  // —— Areas (admin writes) ——
  Future<List<AreaDto>> getAreas() async {
    final Response<dynamic> response = await _dio.get<dynamic>("/areas");
    final List<dynamic> list = response.data as List<dynamic>;
    return list
        .map(
          (dynamic e) => AreaDto.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false);
  }

  Future<AreaDto> adminCreateArea({
    required String nameEn,
    required String nameAr,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      "/areas",
      data: <String, dynamic>{"nameEn": nameEn, "nameAr": nameAr},
    );
    return AreaDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AreaDto> adminUpdateArea(
    String id, {
    String? nameEn,
    String? nameAr,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{};
    if (nameEn != null) body["nameEn"] = nameEn;
    if (nameAr != null) body["nameAr"] = nameAr;
    final Response<dynamic> response =
        await _dio.put<dynamic>("/areas/$id", data: body);
    return AreaDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> adminDeleteArea(String id) async {
    await _dio.delete<dynamic>("/areas/$id");
  }

  // —— Restaurants (admin) ——
  Future<RestaurantDto> adminCreateRestaurant({
    required String nameEn,
    required String nameAr,
    String? descriptionEn,
    String? descriptionAr,
    String? logoUrl,
    String? phone,
    List<String>? categoryIds,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      "/restaurants",
      data: <String, dynamic>{
        "nameEn": nameEn,
        "nameAr": nameAr,
        if (descriptionEn != null) "descriptionEn": descriptionEn,
        if (descriptionAr != null) "descriptionAr": descriptionAr,
        if (logoUrl != null) "logoUrl": logoUrl,
        if (phone != null) "phone": phone,
        if (categoryIds != null) "categoryIds": categoryIds,
      },
    );
    return RestaurantDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RestaurantDto> adminUpdateRestaurant(
    String id, {
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
    String? logoUrl,
    String? phone,
    List<String>? categoryIds,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{};
    if (nameEn != null) body["nameEn"] = nameEn;
    if (nameAr != null) body["nameAr"] = nameAr;
    if (descriptionEn != null) body["descriptionEn"] = descriptionEn;
    if (descriptionAr != null) body["descriptionAr"] = descriptionAr;
    if (logoUrl != null) body["logoUrl"] = logoUrl;
    if (phone != null) body["phone"] = phone;
    if (categoryIds != null) body["categoryIds"] = categoryIds;
    final Response<dynamic> response =
        await _dio.put<dynamic>("/restaurants/$id", data: body);
    return RestaurantDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> adminDeleteRestaurant(String id) async {
    await _dio.delete<dynamic>("/restaurants/$id");
  }

  Future<void> adminAssignRestaurantCategories(
    String restaurantId,
    List<String> categoryIds,
  ) async {
    await _dio.post<dynamic>(
      "/restaurant-categories/$restaurantId/assign",
      data: <String, dynamic>{"categoryIds": categoryIds},
    );
  }

  Future<void> adminUnassignRestaurantCategory(
    String restaurantId,
    String categoryId,
  ) async {
    await _dio.delete<dynamic>(
      "/restaurant-categories/$restaurantId/$categoryId",
    );
  }

  // —— Branches (admin) ——
  Future<BranchDto> adminCreateBranch({
    required String restaurantId,
    required String nameEn,
    required String nameAr,
    String? areaId,
    String? address,
    String? latitude,
    String? longitude,
    int? costLevel,
    int? isOpen,
    String? openTime,
    String? closeTime,
    List<String>? facilityIds,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      "/branches",
      data: <String, dynamic>{
        "restaurantId": restaurantId,
        "nameEn": nameEn,
        "nameAr": nameAr,
        if (areaId != null && areaId.isNotEmpty) "areaId": areaId,
        if (address != null) "address": address,
        if (latitude != null) "latitude": latitude,
        if (longitude != null) "longitude": longitude,
        if (costLevel != null) "costLevel": costLevel,
        if (isOpen != null) "isOpen": isOpen,
        if (openTime != null) "openTime": openTime,
        if (closeTime != null) "closeTime": closeTime,
        if (facilityIds != null) "facilityIds": facilityIds,
      },
    );
    return BranchDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BranchDto> adminUpdateBranch(
    String id, {
    String? restaurantId,
    String? areaId,
    String? nameEn,
    String? nameAr,
    String? address,
    String? latitude,
    String? longitude,
    int? costLevel,
    int? isOpen,
    String? openTime,
    String? closeTime,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{};
    if (restaurantId != null) body["restaurantId"] = restaurantId;
    if (areaId != null) body["areaId"] = areaId;
    if (nameEn != null) body["nameEn"] = nameEn;
    if (nameAr != null) body["nameAr"] = nameAr;
    if (address != null) body["address"] = address;
    if (latitude != null) body["latitude"] = latitude;
    if (longitude != null) body["longitude"] = longitude;
    if (costLevel != null) body["costLevel"] = costLevel;
    if (isOpen != null) body["isOpen"] = isOpen;
    if (openTime != null) body["openTime"] = openTime;
    if (closeTime != null) body["closeTime"] = closeTime;
    final Response<dynamic> response =
        await _dio.put<dynamic>("/branches/$id", data: body);
    return BranchDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> adminDeleteBranch(String id) async {
    await _dio.delete<dynamic>("/branches/$id");
  }

  Future<List<String>> adminGetBranchFacilityIds(String branchId) async {
    final Response<dynamic> response =
        await _dio.get<dynamic>("/branches/$branchId/facilities");
    final List<dynamic> list = response.data as List<dynamic>;
    return list.map((dynamic e) => e.toString()).toList(growable: false);
  }

  Future<void> adminAssignBranchFacilities(
    String branchId,
    List<String> facilityIds,
  ) async {
    await _dio.post<dynamic>(
      "/branches/$branchId/facilities",
      data: <String, dynamic>{"facilityIds": facilityIds},
    );
  }

  Future<void> adminUnassignBranchFacility(
    String branchId,
    String facilityId,
  ) async {
    await _dio.delete<dynamic>("/branches/$branchId/facilities/$facilityId");
  }

  /// Uploads file to `/upload/single`, then registers URL on the branch.
  Future<void> adminUploadMenuImage({
    required String branchId,
    required List<int> imageBytes,
    required String filename,
    int displayOrder = 0,
  }) async {
    final FormData uploadForm = FormData.fromMap(<String, dynamic>{
      "file": MultipartFile.fromBytes(imageBytes, filename: filename),
    });
    final Response<dynamic> uploadRes =
        await _dio.post<dynamic>("/upload/single", data: uploadForm);
    final dynamic root = uploadRes.data;
    final dynamic data =
        root is Map<String, dynamic> && root["data"] != null
            ? root["data"]
            : root;
    final String url = (data is Map && data["url"] != null)
        ? data["url"].toString()
        : "";
    if (url.isEmpty) {
      throw StateError("Upload did not return a URL");
    }
    await _dio.post<dynamic>(
      "/branches/$branchId/menu-images",
      data: <String, dynamic>{
        "imageUrl": url,
        "displayOrder": displayOrder,
      },
    );
  }

  Future<void> adminDeleteMenuImage(String imageId) async {
    await _dio.delete<dynamic>("/menu-images/$imageId");
  }

  Future<void> adminReorderMenuImages(
    String branchId,
    List<String> imageIds,
  ) async {
    await _dio.post<dynamic>(
      "/branches/$branchId/menu-images/reorder",
      data: <String, dynamic>{"imageIds": imageIds},
    );
  }

  // —— Restaurant photos (admin) ——
  Future<void> adminCreateRestaurantPhoto({
    required String restaurantId,
    required String imageUrl,
    String? caption,
    int displayOrder = 0,
  }) async {
    await _dio.post<dynamic>(
      "/restaurants/$restaurantId/photos",
      data: <String, dynamic>{
        "imageUrl": imageUrl,
        if (caption != null) "caption": caption,
        "displayOrder": displayOrder,
      },
    );
  }

  Future<void> adminDeleteRestaurantPhoto(String photoId) async {
    await _dio.delete<dynamic>("/restaurant-photos/$photoId");
  }

  // —— Offers (admin) ——
  Future<List<OfferDto>> adminGetAllOffers() async {
    final Response<dynamic> response = await _dio.get<dynamic>("/offers/all");
    final List<dynamic> list = response.data as List<dynamic>;
    return list
        .map(
          (dynamic e) =>
              OfferDto.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false);
  }

  Future<OfferDto> adminCreateOffer({
    required String restaurantId,
    required String title,
    String? description,
    String? imageUrl,
    String? startDate,
    String? endDate,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      "/offers",
      data: <String, dynamic>{
        "restaurantId": restaurantId,
        "title": title,
        if (description != null) "description": description,
        if (imageUrl != null) "imageUrl": imageUrl,
        if (startDate != null) "startDate": startDate,
        if (endDate != null) "endDate": endDate,
      },
    );
    return OfferDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OfferDto> adminUpdateOffer(
    String id, {
    String? restaurantId,
    String? title,
    String? description,
    String? imageUrl,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{};
    if (restaurantId != null) body["restaurantId"] = restaurantId;
    if (title != null) body["title"] = title;
    if (description != null) body["description"] = description;
    if (imageUrl != null) body["imageUrl"] = imageUrl;
    if (startDate != null) body["startDate"] = startDate;
    if (endDate != null) body["endDate"] = endDate;
    final Response<dynamic> response =
        await _dio.put<dynamic>("/offers/$id", data: body);
    return OfferDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> adminDeleteOffer(String id) async {
    await _dio.delete<dynamic>("/offers/$id");
  }

  // —— Users (admin) ——
  Future<List<AdminUserDto>> adminListUsers({
    int limit = 50,
    int offset = 0,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      "/users",
      queryParameters: <String, dynamic>{
        "limit": limit,
        "offset": offset,
      },
    );
    final List<dynamic> list = response.data as List<dynamic>;
    return list
        .map(
          (dynamic e) =>
              AdminUserDto.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false);
  }

  Future<AdminUserDto> adminGetUser(String id) async {
    final Response<dynamic> response = await _dio.get<dynamic>("/users/$id");
    return AdminUserDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<RestaurantDto>> getRestaurants({
    String? categoryId,
    String? search,
    int? minCostLevel,
    int? maxCostLevel,
    bool? openOnly,
    String? sort,
    List<String>? facilityIds,
    int? limit,
    int? offset,
  }) async {
    final response = await _dio.get<dynamic>(
      "/restaurants",
      queryParameters: <String, dynamic>{
        if (categoryId != null && categoryId.isNotEmpty)
          "categoryId": categoryId,
        if (search != null && search.isNotEmpty) "search": search,
        if (minCostLevel != null) "minCostLevel": minCostLevel,
        if (maxCostLevel != null) "maxCostLevel": maxCostLevel,
        if (openOnly != null) "openOnly": openOnly,
        if (sort != null && sort.isNotEmpty) "sort": sort,
        if (facilityIds != null && facilityIds.isNotEmpty)
          "facilityIds": facilityIds.join(","),
        if (limit != null) "limit": limit,
        if (offset != null) "offset": offset,
      },
    );
    final envelope = ApiEnvelope.fromDynamic<List<RestaurantDto>>(
      response.data,
      (dynamic data) {
        final list = data as List<dynamic>;
        return list
            .map(
              (dynamic item) =>
                  RestaurantDto.fromJson(item as Map<String, dynamic>),
            )
            .toList(growable: false);
      },
    );
    return envelope.data;
  }

  Future<BranchDto> getBranch(String id) async {
    final Response<dynamic> response =
        await _dio.get<dynamic>("/branches/$id");
    return BranchDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<BranchDto>> getBranches({
    String? restaurantId,
    String? areaId,
  }) async {
    final response = await _dio.get<dynamic>(
      "/branches",
      queryParameters: <String, dynamic>{
        if (restaurantId != null && restaurantId.isNotEmpty)
          "restaurantId": restaurantId,
        if (areaId != null && areaId.isNotEmpty) "areaId": areaId,
      },
    );
    final envelope = ApiEnvelope.fromDynamic<List<BranchDto>>(response.data, (
      dynamic data,
    ) {
      final list = data as List<dynamic>;
      return list
          .map(
            (dynamic item) => BranchDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
    });
    return envelope.data;
  }

  Future<Map<String, dynamic>> getRestaurantDetails(String id) async {
    final Response<dynamic> response =
        await _dio.get<dynamic>("/restaurants/$id/details");
    return response.data as Map<String, dynamic>;
  }

  Future<List<BranchDto>> getNearbyBranches({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.get<dynamic>(
      "/branches/nearby",
      queryParameters: <String, dynamic>{
        "lat": latitude,
        "lng": longitude,
      },
    );
    final envelope = ApiEnvelope.fromDynamic<List<BranchDto>>(response.data, (
      dynamic data,
    ) {
      final list = data as List<dynamic>;
      return list
          .map(
            (dynamic item) =>
                BranchDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
    });
    return envelope.data;
  }

  Future<List<OfferDto>> getOffers() async {
    final response = await _dio.get<dynamic>("/offers");
    final envelope = ApiEnvelope.fromDynamic<List<OfferDto>>(response.data, (
      dynamic data,
    ) {
      final list = data as List<dynamic>;
      return list
          .map(
            (dynamic item) => OfferDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
    });
    return envelope.data;
  }

  Future<Map<String, int>> getBranchVotes(String branchId) async {
    final response = await _dio.get<dynamic>("/votes/branches/$branchId/votes");
    final payload = response.data as Map<String, dynamic>;
    return <String, int>{
      "upVotes": int.tryParse((payload["upVotes"] ?? 0).toString()) ?? 0,
      "downVotes": int.tryParse((payload["downVotes"] ?? 0).toString()) ?? 0,
    };
  }

  Future<List<FacilityDto>> getFacilities() async {
    final Response<dynamic> response =
        await _dio.get<dynamic>("/facilities");
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map(
          (dynamic item) =>
              FacilityDto.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  Future<void> voteForBranch(String branchId, int vote) async {
    await _dio.post<dynamic>(
      "/votes/branches/$branchId/vote",
      data: <String, dynamic>{"vote": vote},
    );
  }

  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<dynamic>(
      "/users/login",
      data: <String, dynamic>{"email": email, "password": password},
    );
    return LoginResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String birthDate,
    required String gender,
    required String phoneNumber,
  }) async {
    await _dio.post<dynamic>(
      "/users",
      data: <String, dynamic>{
        "name": name,
        "email": email,
        "password": password,
        "birthDate": birthDate,
        "gender": gender,
        "phoneNumber": phoneNumber,
      },
    );
  }

  Future<void> forgotPassword({required String email}) async {
    await _dio.post<dynamic>(
      "/users/forgot-password",
      data: <String, dynamic>{"email": email},
    );
  }

  Future<Set<String>> getFavoriteRestaurantIds() async {
    final Response<dynamic> response = await _dio.get<dynamic>("/favorites");
    dynamic raw = response.data;
    if (raw is Map<String, dynamic> && raw.containsKey("data")) {
      raw = raw["data"];
    }
    final List<dynamic> list =
        raw is List<dynamic> ? raw : <dynamic>[];
    return list
        .map(
          (dynamic item) => (item as Map<String, dynamic>)["restaurantId"]
              ?.toString(),
        )
        .whereType<String>()
        .toSet();
  }

  Future<void> addFavorite(String restaurantId) async {
    await _dio.post<dynamic>("/favorites/$restaurantId");
  }

  Future<void> removeFavorite(String restaurantId) async {
    await _dio.delete<dynamic>("/favorites/$restaurantId");
  }

  Future<ReviewsState> getBranchReviews(String branchId) async {
    final Response<dynamic> response =
        await _dio.get<dynamic>("/reviews/branches/$branchId/reviews");
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    final List<dynamic> list = data["reviews"] as List<dynamic>? ?? <dynamic>[];
    final Map<String, dynamic> summary =
        data["summary"] as Map<String, dynamic>? ?? <String, dynamic>{};

    final List<ReviewEntity> reviews = list
        .map(
          (dynamic item) {
            final Map<String, dynamic> map =
                item as Map<String, dynamic>;
            return ReviewEntity(
              id: map["id"].toString(),
              userName: (map["userName"] as String?) ?? "User",
              rating: int.tryParse(map["rating"].toString()) ?? 0,
              comment: (map["comment"] as String?) ?? "",
              createdAt: DateTime.tryParse(
                    map["createdAt"]?.toString() ?? "",
                  ) ??
                  DateTime.now(),
            );
          },
        )
        .toList(growable: false);

    final ReviewSummary summaryEntity = ReviewSummary(
      avgRating:
          double.tryParse(summary["avgRating"]?.toString() ?? "0") ?? 0,
      total: int.tryParse(summary["total"]?.toString() ?? "0") ?? 0,
    );

    return ReviewsState(reviews: reviews, summary: summaryEntity);
  }

  Future<void> submitReview({
    required String branchId,
    required int rating,
    String? comment,
  }) async {
    await _dio.post<dynamic>(
      "/reviews/branches/$branchId/reviews",
      data: <String, dynamic>{
        "rating": rating,
        if (comment != null && comment.isNotEmpty) "comment": comment,
      },
    );
  }

  Future<List<MenuImageEntity>> getBranchMenuImages(String branchId) async {
    final Response<dynamic> response =
        await _dio.get<dynamic>("/branches/$branchId/menu-images");
    final ApiEnvelope<List<MenuImageEntity>> envelope =
        ApiEnvelope.fromDynamic<List<MenuImageEntity>>(
      response.data,
      (dynamic data) {
        final List<dynamic> list = data as List<dynamic>;
        return list
            .map(
              (dynamic item) => MenuImageEntity.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(growable: false);
      },
    );
    return envelope.data;
  }

  Future<List<RestaurantPhotoEntity>> getRestaurantPhotos(
    String restaurantId,
  ) async {
    final Response<dynamic> response =
        await _dio.get<dynamic>("/restaurants/$restaurantId/photos");
    final ApiEnvelope<List<RestaurantPhotoEntity>> envelope =
        ApiEnvelope.fromDynamic<List<RestaurantPhotoEntity>>(
      response.data,
      (dynamic data) {
        final List<dynamic> list = data as List<dynamic>;
        return list
            .map(
              (dynamic item) => RestaurantPhotoEntity.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(growable: false);
      },
    );
    return envelope.data;
  }
}

final menuApiProvider = Provider<MenuApi>((Ref ref) {
  return MenuApi(ref.watch(dioProvider));
});
