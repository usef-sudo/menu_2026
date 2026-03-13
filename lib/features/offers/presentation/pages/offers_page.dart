import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/features/offers/presentation/controllers/offers_controller.dart";

class OffersPage extends ConsumerWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(offersControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Offers")),
      body: offersAsync.when(
        data: (offers) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final offer = offers[index];
            return ListTile(
              title: Text(offer.title),
              subtitle: Text(
                offer.description.isEmpty
                    ? "No description"
                    : offer.description,
              ),
            );
          },
          separatorBuilder: (context, index) => const Divider(),
          itemCount: offers.length,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text("Unable to load offers")),
      ),
    );
  }
}
