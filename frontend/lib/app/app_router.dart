import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';

import '../features/home/presentation/pages/home_page.dart';

import '../features/building/presentation/pages/building_list_page.dart';
import '../features/building/presentation/pages/floor_selection_page.dart';

import '../features/navigation/presentation/pages/buildings_page.dart';
import '../features/navigation/presentation/pages/floors_page.dart';
import '../features/navigation/presentation/pages/navigation_page.dart';

import '../features/maps/presentation/pages/indoor_map_page.dart';

import '../features/search/presentation/pages/search_page.dart';

import '../core/models/room_search_result_model.dart';
import '../features/profile/presentation/pages/profile_page.dart';

import '../features/splash/presentation/pages/splash_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: "/",

  routes: [
    GoRoute(path: "/", builder: (context, state) => const SplashPage()),

    GoRoute(path: "/login", builder: (context, state) => const LoginPage()),

    GoRoute(
      path: "/register",
      builder: (context, state) => const RegisterPage(),
    ),

    GoRoute(
      path: "/forgot-password",
      builder: (context, state) => const ForgotPasswordPage(),
    ),

    GoRoute(
      path: "/reset-password",
      builder: (context, state) {
        final token = state.uri.queryParameters["token"] ?? "";
        return ResetPasswordPage(token: token);
      },
    ),

    GoRoute(path: "/home", builder: (context, state) => const HomePage()),

    GoRoute(
      path: "/buildings",
      builder: (context, state) => const BuildingsPage(),
    ),

    GoRoute(
      path: "/building-list",
      builder: (context, state) => const BuildingListPage(),
    ),

    GoRoute(path: "/search", builder: (context, state) => const SearchPage()),

    GoRoute(path: "/profile", builder: (context, state) => const ProfilePage()),

    GoRoute(
      path: "/navigation",
      builder: (context, state) => const NavigationPage(),
    ),

    GoRoute(
      path: "/floor-selection",
      builder: (context, state) {
        final building = state.uri.queryParameters["building"] ?? "Building";
        final buildingId =
            int.tryParse(state.uri.queryParameters["buildingId"] ?? "") ?? 0;

        return FloorSelectionPage(
          buildingId: buildingId,
          buildingName: building,
        );
      },
    ),

    GoRoute(
      path: "/floors",
      builder: (context, state) {
        final id = int.tryParse(state.uri.queryParameters["id"] ?? "0") ?? 0;

        final name = state.uri.queryParameters["name"] ?? "Building";

        return FloorsPage(buildingId: id, buildingName: name);
      },
    ),

    GoRoute(
      path: "/indoor-map",
      builder: (context, state) {
        final params = state.uri.queryParameters;

        final building = params["building"] ?? "";
        final floor = params["floor"];
        final buildingId = int.tryParse(params["buildingId"] ?? "") ?? 0;
        final floorId = int.tryParse(params["floorId"] ?? "");

        final presetDestination = RoomSearchResultModel.fromQueryParams(
          params,
        );

        return IndoorMapPage(
          buildingId: buildingId,
          buildingName: building,
          floorId: floorId,
          floorName: floor,
          presetDestination: presetDestination,
        );
      },
    ),
  ],

  errorBuilder: (context, state) {
    return Scaffold(
      appBar: AppBar(title: const Text("404")),
      body: const Center(child: Text("Page not found")),
    );
  },
);
