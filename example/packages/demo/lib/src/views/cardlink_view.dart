import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:ia_example_demo/ia_client_config.dart';
import 'package:ia_example_demo/src/file_utils.dart';
import 'package:flutter/material.dart';

class CardLinkViewStateData {
  final userIdController = TextEditingController(text: ExampleAppConfig.cardLinkUserId);
  final cardNameController = TextEditingController();
  final phoneNumberController = TextEditingController(text: '+491234567890');
  final canCodeController = TextEditingController();

  IaCardLinkConsentStatus consentStatus = IaCardLinkConsentStatus.showConsent;
  bool saveCardEnabled = false;
  bool includeCoreAppLogs = false;
  bool usesCustomColors = false;
  IaCardLinkIllustrationColor illustrationColor = IaCardLinkIllustrationColor.red;

  String resultText = '';
  final List<String> eventLog = [];

  void resetControllers() {
    userIdController.clear();
    cardNameController.clear();
    phoneNumberController.clear();
    canCodeController.clear();
  }

  void dispose() {
    userIdController.dispose();
    cardNameController.dispose();
    phoneNumberController.dispose();
    canCodeController.dispose();
  }
}

class CardLinkView extends StatefulWidget {
  const CardLinkView({super.key});

  @override
  State<CardLinkView> createState() => _CardLinkViewStateData();
}

class _CardLinkViewStateData extends State<CardLinkView> {
  static const _customColor = 0xFF2E7D32;

  final _data = CardLinkViewStateData();
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _setupStreamListeners();
  }

  void _setupStreamListeners() {
    final cardLink = IaSdk.instance.cardLink;

    _subscriptions.add(
      cardLink.consentEventListener.stream.listen((event) {
        _addEventLog('Consent: ${event.name}');
      }),
    );

    _subscriptions.add(
      cardLink.sessionCreatedListener.stream.listen((session) {
        _addEventLog('Session created: ${session.data}');
      }),
    );

    _subscriptions.add(
      cardLink.prescriptionsRedeemedListener.stream.listen((prescriptions) {
        _addEventLog('Prescriptions redeemed: $prescriptions');
      }),
    );

    _subscriptions.add(
      cardLink.eventListener.stream.listen((event) {
        _addEventLog('Event: ${event.name}');
      }),
    );

    _subscriptions.add(
      cardLink.analyticsEventListener.stream.listen((event) {
        _addEventLog('Analytics: $event');
      }),
    );

    _subscriptions.add(
      cardLink.consentPhoneNumberListener.stream.listen((phoneNumber) {
        _addEventLog('Consent phone number: $phoneNumber');
      }),
    );

    _subscriptions.add(
      cardLink.savedCardsListener.stream.listen((cards) {
        _addEventLog('Saved cards: ${cards.map((card) => '${card.name} (CAN ${card.canCode})').join(', ')}');
      }),
    );

    _subscriptions.add(
      cardLink.initializationErrorListener.stream.listen((message) {
        _addEventLog('Failed to initialize: ${message ?? 'no description'}');
      }),
    );

    _subscriptions.add(
      cardLink.resultListener.stream.listen((result) {
        _addEventLog('Result: $result');
      }),
    );
  }

  void _addEventLog(String entry) {
    setState(() {
      final timestamp = TimeOfDay.now().format(context);
      _data.eventLog.insert(0, '[$timestamp] $entry');
    });
  }

  Future<String?> _createCoreAppLogFileIfNeeded() async {
    if (!_data.includeCoreAppLogs) return null;
    return await FileUtils.createDemoCoreAppLogFile();
  }

  void _showResult(String result) {
    setState(() {
      _data.resultText = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        24 + MediaQuery.of(context).padding.top,
        20,
        24,
      ),
      children: [
        Text(
          'CardLink Services (${ExampleAppConfig.instance.serverEnvironment.name})',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        _PresetDataSection(
          userIdController: _data.userIdController,
          cardNameController: _data.cardNameController,
          phoneNumberController: _data.phoneNumberController,
          canCodeController: _data.canCodeController,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 24),
        _ConsentStatusSection(
          value: _data.consentStatus,
          onChanged: (value) => setState(() => _data.consentStatus = value),
        ),

        if (Platform.isAndroid) ...[
          const SizedBox(height: 24),
          Text('Illustration Color (Android)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              for (final color in IaCardLinkIllustrationColor.values)
                ChoiceChip(
                  label: Text(color.name),
                  selected: _data.illustrationColor == color,
                  onSelected: (_) => setState(() => _data.illustrationColor = color),
                ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        _LaunchSection(
          saveCardEnabled: _data.saveCardEnabled,
          onSaveCardEnabledChanged: (value) => setState(() => _data.saveCardEnabled = value),
          includeCoreAppLogs: _data.includeCoreAppLogs,
          onIncludeCoreAppLogsChanged: (value) => setState(() => _data.includeCoreAppLogs = value),
          usesCustomColors: _data.usesCustomColors,
          onUsesCustomColorsChanged: (value) => setState(() => _data.usesCustomColors = value),
          onLaunchCardLink: () async {
            try {
              final canCode = _data.canCodeController.text.trim();
              final cardName = _data.cardNameController.text.trim();
              final logFileURL = await _createCoreAppLogFileIfNeeded();
              await IaSdk.instance.cardLink.launch(
                sdkApiKey: ExampleAppConfig.instance.accessKey,
                flowType: IaCardLinkFlowType.cardLink,
                pharmacyId: '2163',
                consentStatus: _data.consentStatus,
                phoneNumber: _data.phoneNumberController.text,
                userId: _data.userIdController.text,
                cardName: cardName.isNotEmpty ? cardName : null,
                canCode: canCode.isNotEmpty ? canCode : null,
                saveCardEnabled: _data.saveCardEnabled,
                environment: null,
                finishAction: IaCardLinkFinishAction.uploadPrescriptions,
                coreAppLogFileURL: logFileURL,
                supportsLiquidGlass: true,
                illustrationColor: _data.illustrationColor,
                primaryColor: _data.usesCustomColors ? _customColor : null,
                buttonsColor: _data.usesCustomColors ? _customColor : null,
                textLinkColor: _data.usesCustomColors ? _customColor : null,
                bottomNavigationColor: _data.usesCustomColors ? _customColor : null,
              );
              _showResult('CardLink launched');
            } catch (e) {
              _showResult('Error: $e');
            }
          },
          onLaunchSavedCards: () async {
            try {
              final canCode = _data.canCodeController.text.trim();
              final cardName = _data.cardNameController.text.trim();
              final logFileURL = await _createCoreAppLogFileIfNeeded();
              await IaSdk.instance.cardLink.launch(
                sdkApiKey: ExampleAppConfig.instance.accessKey,
                flowType: IaCardLinkFlowType.savedCards,
                pharmacyId: '2163',
                consentStatus: _data.consentStatus,
                phoneNumber: _data.phoneNumberController.text,
                userId: _data.userIdController.text,
                cardName: cardName.isNotEmpty ? cardName : null,
                canCode: canCode.isNotEmpty ? canCode : null,
                saveCardEnabled: _data.saveCardEnabled,
                environment: null,
                finishAction: IaCardLinkFinishAction.uploadPrescriptions,
                coreAppLogFileURL: logFileURL,
                supportsLiquidGlass: true,
                illustrationColor: _data.illustrationColor,
                primaryColor: _data.usesCustomColors ? _customColor : null,
                buttonsColor: _data.usesCustomColors ? _customColor : null,
                textLinkColor: _data.usesCustomColors ? _customColor : null,
                bottomNavigationColor: _data.usesCustomColors ? _customColor : null,
              );
              _showResult('Saved Cards launched');
            } catch (e) {
              _showResult('Error: $e');
            }
          },
        ),
        const SizedBox(height: 24),
        _InfoMethodsSection(
          onShowResult: _showResult,
        ),
        const SizedBox(height: 24),
        _CardManagementSection(
          userIdController: _data.userIdController,
          cardNameController: _data.cardNameController,
          onShowResult: _showResult,
        ),
        const SizedBox(height: 24),
        if (_data.resultText.isNotEmpty) ...[
          _ResultSection(
            text: _data.resultText,
            onClear: () => setState(() => _data.resultText = ''),
          ),
          const SizedBox(height: 24),
        ],
        _EventLogSection(
          eventLog: _data.eventLog,
          onClear: () => setState(() => _data.eventLog.clear()),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _data.dispose();
    super.dispose();
  }
}

class _PresetDataSection extends StatelessWidget {
  const _PresetDataSection({
    required this.userIdController,
    required this.cardNameController,
    required this.phoneNumberController,
    required this.canCodeController,
    required this.onChanged,
  });

  final TextEditingController userIdController;
  final TextEditingController cardNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController canCodeController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Preset Data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () {
                userIdController.clear();
                cardNameController.clear();
                phoneNumberController.clear();
                canCodeController.clear();
                onChanged();
              },
              child: Text('Reset All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ClearableTextField(
          controller: userIdController,
          label: 'User ID',
          onCleared: onChanged,
        ),
        const SizedBox(height: 12),
        _ClearableTextField(
          controller: cardNameController,
          label: 'Saved Card Name (optional)',
          hint: 'Starts CardLink with this saved card',
          onCleared: onChanged,
        ),
        const SizedBox(height: 12),
        _ClearableTextField(
          controller: phoneNumberController,
          label: 'Phone Number',
          keyboardType: TextInputType.phone,
          onCleared: onChanged,
        ),
        const SizedBox(height: 12),
        _ClearableTextField(
          controller: canCodeController,
          label: 'CAN Code (optional)',
          hint: '6-digit code from health card',
          keyboardType: TextInputType.number,
          maxLength: 6,
          onCleared: onChanged,
        ),
      ],
    );
  }
}

class _ClearableTextField extends StatelessWidget {
  const _ClearableTextField({
    required this.controller,
    required this.label,
    required this.onCleared,
    this.hint,
    this.keyboardType,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final int? maxLength;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear, size: 18),
          onPressed: () {
            controller.clear();
            onCleared();
          },
        ),
      ),
      keyboardType: keyboardType,
      maxLength: maxLength,
    );
  }
}

class _ConsentStatusSection extends StatelessWidget {
  const _ConsentStatusSection({
    required this.value,
    required this.onChanged,
  });

  final IaCardLinkConsentStatus value;
  final ValueChanged<IaCardLinkConsentStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consent Status',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        RadioGroup<IaCardLinkConsentStatus>(
          groupValue: value,
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
          child: Column(
            children: [
              RadioListTile<IaCardLinkConsentStatus>(
                title: Text('Show Consent'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: IaCardLinkConsentStatus.showConsent,
              ),
              RadioListTile<IaCardLinkConsentStatus>(
                title: Text('Consent Accepted'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: IaCardLinkConsentStatus.consentAccepted,
              ),
              RadioListTile<IaCardLinkConsentStatus>(
                title: Text('Consent Declined'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: IaCardLinkConsentStatus.consentDeclined,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LaunchSection extends StatelessWidget {
  const _LaunchSection({
    required this.saveCardEnabled,
    required this.onSaveCardEnabledChanged,
    required this.includeCoreAppLogs,
    required this.onIncludeCoreAppLogsChanged,
    required this.usesCustomColors,
    required this.onUsesCustomColorsChanged,
    required this.onLaunchCardLink,
    required this.onLaunchSavedCards,
  });

  final bool saveCardEnabled;
  final ValueChanged<bool> onSaveCardEnabledChanged;
  final bool includeCoreAppLogs;
  final ValueChanged<bool> onIncludeCoreAppLogsChanged;
  final bool usesCustomColors;
  final ValueChanged<bool> onUsesCustomColorsChanged;
  final VoidCallback onLaunchCardLink;
  final VoidCallback onLaunchSavedCards;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Launch',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SwitchListTile(
          title: Text('Save Card Enabled'),
          dense: true,
          contentPadding: EdgeInsets.zero,
          value: saveCardEnabled,
          onChanged: onSaveCardEnabledChanged,
        ),
        SwitchListTile(
          title: Text('Include Core App Logs in Report Problem'),
          dense: true,
          contentPadding: EdgeInsets.zero,
          value: includeCoreAppLogs,
          onChanged: onIncludeCoreAppLogsChanged,
        ),
        SwitchListTile(
          title: Text('Custom Colors'),
          subtitle: Text('Green primary, button, link and navigation colors'),
          dense: true,
          contentPadding: EdgeInsets.zero,
          value: usesCustomColors,
          onChanged: onUsesCustomColorsChanged,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.nfc),
          label: Text('Launch CardLink'),
          onPressed: onLaunchCardLink,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.credit_card),
          label: Text('Launch Saved Cards'),
          onPressed: onLaunchSavedCards,
        ),
      ],
    );
  }
}

class _InfoMethodsSection extends StatelessWidget {
  const _InfoMethodsSection({
    required this.onShowResult,
  });

  final ValueChanged<String> onShowResult;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Info Methods',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Get Version'),
          onPressed: () async {
            try {
              final version = await IaSdk.instance.cardLink.getVersion();
              onShowResult('Version: $version');
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Get Environment'),
          onPressed: () async {
            try {
              final environment = await IaSdk.instance.cardLink.getEnvironment();
              onShowResult('Environment: $environment');
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Get Log File Path'),
          onPressed: () async {
            try {
              final logPath = await IaSdk.instance.cardLink.getLogFilePath();
              onShowResult('Log path: $logPath');
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
        if (Platform.isIOS) ...[
          const SizedBox(height: 8),
          ElevatedButton(
            child: Text('Finish CardLink (iOS)'),
            onPressed: () async {
              try {
                await IaSdk.instance.cardLink.finish();
                onShowResult('CardLink finished');
              } catch (e) {
                onShowResult('Error: $e');
              }
            },
          ),
        ],
      ],
    );
  }
}

class _CardManagementSection extends StatelessWidget {
  const _CardManagementSection({
    required this.userIdController,
    required this.cardNameController,
    required this.onShowResult,
  });

  final TextEditingController userIdController;
  final TextEditingController cardNameController;
  final ValueChanged<String> onShowResult;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Management',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Get Saved Cards'),
          onPressed: () async {
            try {
              final cardsJson = await IaSdk.instance.cardLink.getSavedCards(
                userIdController.text,
              );
              if (cardsJson == null || cardsJson.isEmpty) {
                onShowResult('No saved cards found.');
                return;
              }
              final formatted = const JsonEncoder.withIndent('  ').convert(
                jsonDecode(cardsJson),
              );
              onShowResult('Saved cards:\n$formatted');
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Get Saved Card List'),
          onPressed: () async {
            try {
              final cards = await IaSdk.instance.cardLink.getSavedCardList(userIdController.text);
              onShowResult(
                cards.isEmpty
                    ? 'No saved cards found.'
                    : cards.map((card) => '${card.name}: CAN ${card.canCode}, phone ${card.phoneNumber}, id ${card.id}').join('\n'),
              );
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        if (Platform.isAndroid) ...[
          ElevatedButton(
            child: Text('Rename Saved Card (Android)'),
            onPressed: () async {
              try {
                final cards = await IaSdk.instance.cardLink.getSavedCardList(userIdController.text);
                final card = cards.where((card) => card.name == cardNameController.text).firstOrNull;
                if (card == null) {
                  onShowResult('No saved card named "${cardNameController.text}".');
                  return;
                }
                final newName = '${card.name} (renamed)';
                await IaSdk.instance.cardLink.updateCard(
                  userId: userIdController.text,
                  originalName: card.name,
                  name: newName,
                  phoneNumber: card.phoneNumber ?? '',
                  canCode: card.canCode ?? '',
                );
                onShowResult('Renamed "${card.name}" to "$newName".');
              } catch (e) {
                onShowResult('Error: $e');
              }
            },
          ),
          const SizedBox(height: 8),
        ],
        ElevatedButton(
          child: Text('Attach Host Log File to Problem Reports'),
          onPressed: () async {
            try {
              final path = await FileUtils.createDemoCoreAppLogFile();
              await IaSdk.instance.cardLink.setHostAppLogFilePath(path);
              onShowResult('Host log file attached: $path');
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Delete Card'),
          onPressed: () async {
            try {
              await IaSdk.instance.cardLink.deleteCard(
                userId: userIdController.text,
                cardName: cardNameController.text,
              );
              onShowResult('Card "${cardNameController.text}" deleted.');
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        if (Platform.isIOS) ...[
          ElevatedButton(
            child: Text('Mock CardLink Backend (iOS)'),
            onPressed: () async {
              try {
                await IaSdk.instance.cardLink.setMocks(const IaCardLinkMocks());
                onShowResult('CardLink backend mocks enabled.');
              } catch (e) {
                onShowResult('Error: $e');
              }
            },
          ),
          const SizedBox(height: 8),
        ],
        if (Platform.isAndroid) ...[
          ElevatedButton(
            child: Text('Reverse Saved Cards Order (Android)'),
            onPressed: () async {
              try {
                final cards = await IaSdk.instance.cardLink.getSavedCardList(
                  userIdController.text,
                );
                await IaSdk.instance.cardLink.reorderSavedCards(
                  userId: userIdController.text,
                  orderedCanCodes: cards.reversed.map((card) => card.canCode).whereType<String>().toList(),
                );
                onShowResult('Reversed the order of ${cards.length} saved card(s).');
              } catch (e) {
                onShowResult('Error: $e');
              }
            },
          ),
          const SizedBox(height: 8),
        ],
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red.shade700,
          ),
          child: Text('Delete All Cards'),
          onPressed: () async {
            try {
              final status = await IaSdk.instance.cardLink.deleteAllCards();
              onShowResult('Delete all cards: $status');
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red.shade700,
          ),
          child: Text('Delete All User Related Data'),
          onPressed: () async {
            try {
              await IaSdk.instance.cardLink.deleteAllUserRelatedData();
              onShowResult('All user related data deleted.');
            } catch (e) {
              onShowResult('Error: $e');
            }
          },
        ),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.text,
    required this.onClear,
  });

  final String text;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Result',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: onClear,
              child: Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            text,
            style: TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}

class _EventLogSection extends StatelessWidget {
  const _EventLogSection({
    required this.eventLog,
    required this.onClear,
  });

  final List<String> eventLog;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Event Log',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (eventLog.isNotEmpty)
              TextButton(
                onPressed: onClear,
                child: Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: eventLog.isEmpty
              ? Center(
                  child: Text(
                    'No events yet.\nLaunch CardLink to see live events.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: eventLog.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: SelectableText(
                        eventLog[index],
                        style: TextStyle(
                          color: Colors.green.shade300,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
