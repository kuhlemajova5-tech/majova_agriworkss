import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:majova_agriworks/screens/livestock/livestock_screen.dart';
import 'package:majova_agriworks/screens/tasks/task_screen.dart';
import 'package:majova_agriworks/screens/crops/crop_screen.dart';
import 'package:majova_agriworks/screens/inventory/inventory_screen.dart';
import 'package:majova_agriworks/screens/finance/finance_screen.dart';
import 'package:majova_agriworks/screens/tractors/tractor_screen.dart';

void main() {
  Future<void> openScreen(
      WidgetTester tester,
      Widget screen,
      ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(home: screen),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  group('Majova AgriWorks - Livestock Management', () {
    testWidgets('livestock screen opens successfully',
            (WidgetTester tester) async {
          await openScreen(tester, const LivestockScreen());

          expect(find.byType(LivestockScreen), findsOneWidget);
          expect(find.text('Livestock Management'), findsOneWidget);
          expect(find.text('Manage Your Livestock'), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

    testWidgets('initial statistics are displayed',
            (WidgetTester tester) async {
          await openScreen(tester, const LivestockScreen());

          expect(find.text('Total Animals'), findsOneWidget);
          expect(find.text('Animal Groups'), findsOneWidget);
          expect(find.text('Healthy Animals'), findsOneWidget);
          expect(find.text('Needs Attention'), findsOneWidget);
        });

    testWidgets('empty livestock message is displayed',
            (WidgetTester tester) async {
          await openScreen(tester, const LivestockScreen());

          final emptyMessage =
          find.text('No livestock records found');

          await tester.scrollUntilVisible(
            emptyMessage,
            300,
            scrollable: find.byType(Scrollable).first,
          );

          expect(emptyMessage, findsOneWidget);
          expect(find.text('Add Livestock'), findsWidgets);
        });

    testWidgets('search field is displayed',
            (WidgetTester tester) async {
          await openScreen(tester, const LivestockScreen());

          final searchField = find.byType(TextField);

          await tester.scrollUntilVisible(
            searchField,
            300,
            scrollable: find.byType(Scrollable).first,
          );

          expect(searchField, findsOneWidget);
          expect(
            find.text('Search by name, ID or breed...'),
            findsOneWidget,
          );
        });

    testWidgets('animal type filters are displayed',
            (WidgetTester tester) async {
          await openScreen(tester, const LivestockScreen());

          final searchField = find.byType(TextField);

          await tester.scrollUntilVisible(
            searchField,
            300,
            scrollable: find.byType(Scrollable).first,
          );

          for (final filter in [
            'All',
            'Sheep',
            'Goats',
            'Cattle',
            'Poultry',
            'Other',
          ]) {
            expect(find.text(filter), findsOneWidget);
          }
        });

    testWidgets('animal care sections are displayed',
            (WidgetTester tester) async {
          await openScreen(tester, const LivestockScreen());

          for (final section in [
            'Your Livestock',
            'Animal Care',
            'Health Records',
            'Vaccinations',
            'Breeding Records',
            'Feeding Records',
            'Weight Records',
          ]) {
            final sectionFinder = find.text(section);

            await tester.scrollUntilVisible(
              sectionFinder,
              300,
              scrollable: find.byType(Scrollable).first,
            );

            expect(sectionFinder, findsOneWidget);
          }
        });

    testWidgets('livestock search accepts text',
            (WidgetTester tester) async {
          await openScreen(tester, const LivestockScreen());

          final searchField = find.byType(TextField);

          await tester.scrollUntilVisible(
            searchField,
            300,
            scrollable: find.byType(Scrollable).first,
          );

          await tester.enterText(searchField, 'Sheep');
          await tester.pumpAndSettle();

          expect(find.byType(LivestockScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
  });

  group('Majova AgriWorks - Tasks', () {
    testWidgets('tasks screen opens successfully',
            (WidgetTester tester) async {
          await openScreen(tester, const TaskScreen());

          expect(find.byType(TaskScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
  });

  group('Majova AgriWorks - Crops', () {
    testWidgets('crops screen opens successfully',
            (WidgetTester tester) async {
          await openScreen(tester, const CropScreen());

          expect(find.byType(CropScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
  });

  group('Majova AgriWorks - Inventory', () {
    testWidgets('inventory screen opens successfully',
            (WidgetTester tester) async {
          await openScreen(tester, const InventoryScreen());

          expect(find.byType(InventoryScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
  });

  group('Majova AgriWorks - Finance', () {
    testWidgets('finance screen opens successfully',
            (WidgetTester tester) async {
          await openScreen(tester, const FinanceScreen());

          expect(find.byType(FinanceScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
  });

  group('Majova AgriWorks - Tractors', () {
    testWidgets('tractors screen opens successfully',
            (WidgetTester tester) async {
          await openScreen(tester, const TractorScreen());

          expect(find.byType(TractorScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
  });
}

