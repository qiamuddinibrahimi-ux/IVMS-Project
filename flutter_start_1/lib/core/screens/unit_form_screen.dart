import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/unit_model.dart';
import '../providers/unit_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

class UnitFormScreen extends StatefulWidget {
  final UnitModel? unit;

  const UnitFormScreen({
    super.key,
    this.unit,
  });

  @override
  State<UnitFormScreen> createState() => _UnitFormScreenState();
}

class _UnitFormScreenState extends State<UnitFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _unitNameController;

  bool get isEditing => widget.unit != null;

  @override
  void initState() {
    super.initState();

    _unitNameController = TextEditingController(
      text: widget.unit?.unitName ?? '',
    );
  }

  @override
  void dispose() {
    _unitNameController.dispose();
    super.dispose();
  }

  Future<void> _saveUnit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final unitName = _unitNameController.text.trim();

    final provider = context.read<UnitProvider>();

    bool success;

    if (isEditing) {
      success = await provider.updateUnit(
        unitId: widget.unit!.unitId,
        unitName: unitName,
      );
    } else {
      success = await provider.createUnit(
        unitName: unitName,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      _showError(provider.errorMessage);
    }
  }

  void _showError(String? message) {
    if (!mounted) return;

    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ??
            (loc.getString('something_wrong') ?? 'Something went wrong.')),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          isEditing
              ? (loc.getString('edit_unit') ?? 'Edit Unit')
              : (loc.getString('add_unit') ?? 'Add Unit'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<UnitProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // HEADER
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF102C4A)
                          : const Color(0xFF102C4A).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.straighten,
                          size: 60,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF102C4A),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isEditing
                              ? (loc.getString('update_unit_short') ??
                                  'Update Unit')
                              : (loc.getString('create_new_unit') ??
                                  'Create New Unit'),
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : const Color(0xFF102C4A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isEditing
                              ? (loc.getString('change_unit_name_hint') ??
                                  'Change the unit name below.')
                              : (loc.getString('new_unit_hint') ??
                                  'Enter a name for the new unit.'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // UNIT NAME
                  TextFormField(
                    controller: _unitNameController,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.text,
                    textDirection: Directionality.of(context),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText:
                          loc.getString('unit_name') ?? 'Unit Name',
                      labelStyle: TextStyle(color: theme.hintColor),
                      hintText:
                          loc.getString('enter_unit_name') ??
                              'Example: Kilogram',
                      hintStyle: TextStyle(color: theme.hintColor),
                      prefixIcon: Icon(
                        Icons.straighten,
                        color: theme.hintColor,
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return loc.getString('unit_name_required') ??
                            'Unit name is required.';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      _saveUnit();
                    },
                  ),

                  const SizedBox(height: 28),

                  // QIAMUDDIN SAVE BUTTON
                  QiamuddinDesign.primaryButton(
                    context: context,
                    text: provider.isLoading
                        ? (loc.getString('saving') ?? 'Saving...')
                        : isEditing
                            ? (loc.getString('update_unit') ??
                                'Update Unit')
                            : (loc.getString('create_unit') ??
                                'Create Unit'),
                    icon: isEditing ? Icons.save_rounded : Icons.add_rounded,
                    isLoading: provider.isLoading,
                    onPressed: _saveUnit,
                  ),

                  const SizedBox(height: 12),

                  // CANCEL
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(color: theme.dividerColor),
                      ),
                      child: Text(
                        loc.getString('cancel_action') ?? 'Cancel',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}